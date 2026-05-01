using BookingApp.API.Extentions;
using BookingApp.Domain.Entities;
using BookingApp.Domain.Exceptions;
using BookingApp.Infrastructure.Data;
using FastEndpoints;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Scheduling.GetUnavailableDates;

public sealed record GetUnavailableDatesRequest(
	DateTime StartDate,
	DateTime EndDate,
	Guid ServiceId,
	Guid? ClientId = null);

public sealed class GetUnavailableDatesValidator : Validator<GetUnavailableDatesRequest>
{
	public GetUnavailableDatesValidator()
	{
		RuleFor(x => x.StartDate).NotEmpty();
		RuleFor(x => x.EndDate).NotEmpty();
		RuleFor(x => x.ServiceId).NotEmpty();
		RuleFor(x => x.EndDate)
			.GreaterThanOrEqualTo(x => x.StartDate)
			.WithMessage("A data final deve ser maior ou igual à data inicial.");
	}
}

public sealed class GetUnavailableDatesEndpoint(ApplicationDbContext dbContext)
	: Endpoint<GetUnavailableDatesRequest, List<DateTime>>
{
	public override void Configure()
	{
		Get("/appointments/unavailable-dates");
		Policies("All");
		Tags("Application");
		Options(x => x.WithName("GetUnavailableDates"));
	}

	public override async Task HandleAsync(GetUnavailableDatesRequest req, CancellationToken ct)
	{
		var startDate = req.StartDate.EnsureUtcDate();
		var endDate = req.EndDate.EnsureUtcDate();
		var endDateExclusive = endDate.AddDays(1);

		var service = await dbContext.Services
			.AsNoTracking()
			.SingleOrDefaultAsync(s => s.Id == req.ServiceId, ct);

		if (service is null)
			throw new NotFoundException("Serviço não encontrado.");

		var duration = service.DefaultDuration;

		if (req.ClientId.HasValue)
		{
			var clientDuration = await dbContext.ClientServiceDurations
				.AsNoTracking()
				.SingleOrDefaultAsync(c => c.ClientId == req.ClientId.Value && c.ServiceId == req.ServiceId, ct);

			if (clientDuration is not null)
			{
				duration = clientDuration.Duration;
			}
		}

		var durationMinutes = duration.TotalMinutes;
		var startBusinessHours = new TimeSpan(9, 0, 0);
		var endBusinessHours = new TimeSpan(18, 0, 0);

		var absences = await dbContext.AbsenceDays
			.AsNoTracking()
			.Where(a => a.StartDate < endDateExclusive && a.EndDate > startDate)
			.ToListAsync(ct);

		var existingAppointments = await dbContext.Appointments
			.AsNoTracking()
			.Where(a =>
				a.Status == AppointmentStatus.Scheduled &&
				a.StartTime >= startDate &&
				a.StartTime < endDateExclusive)
			.OrderBy(a => a.StartTime)
			.Select(a => new { a.StartTime, a.EndTime })
			.ToListAsync(ct);

		var unavailableDates = new List<DateTime>();

		for (var currentDate = startDate; currentDate <= endDate; currentDate = currentDate.AddDays(1))
		{
			var hasAvailableSlot = false;

			var dayAppointments = existingAppointments
				.Where(a => a.StartTime.Date == currentDate)
				.ToList();

			var dayAbsences = absences
				.Where(a => a.StartDate < currentDate.AddDays(1) && a.EndDate > currentDate)
				.ToList();

			var currentSlot = startBusinessHours;

			while (currentSlot.Add(TimeSpan.FromMinutes(durationMinutes)) <= endBusinessHours)
			{
				var slotStartTime = currentDate.Add(currentSlot);
				var slotEndTime = slotStartTime.AddMinutes(durationMinutes);

				var hasAppointmentOverlap = dayAppointments.Any(a =>
					a.StartTime < slotEndTime && a.EndTime > slotStartTime);

				var hasAbsenceOverlap = dayAbsences.Any(a =>
					a.StartDate < slotEndTime && a.EndDate > slotStartTime);

				if (!hasAppointmentOverlap && !hasAbsenceOverlap)
				{
					hasAvailableSlot = true;
					break;
				}

				currentSlot = currentSlot.Add(TimeSpan.FromMinutes(30));
			}

			if (!hasAvailableSlot)
			{
				unavailableDates.Add(currentDate);
			}
		}

		await Send.OkAsync(unavailableDates, cancellation: ct);
	}
}
