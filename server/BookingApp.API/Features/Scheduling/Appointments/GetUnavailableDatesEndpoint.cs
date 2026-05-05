using BookingApp.API.Extentions;
using BookingApp.API.Features.Scheduling.Appointments;
using BookingApp.Domain.Entities;
using BookingApp.Domain.Exceptions;
using BookingApp.Infrastructure.Data;
using BookingApp.Infrastructure.Settings.Authentication;
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
	private sealed record AppointmentWindow(DateTime StartTime, DateTime EndTime);
	private sealed record AbsenceWindow(DateTime StartDate, DateTime EndDate);

	public override void Configure()
	{
		Get("/appointments/unavailable-dates");
		Policies(UserPolicy.All);
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
			.Select(a => new AppointmentWindow(a.StartTime, a.EndTime))
			.ToListAsync(ct);

		var unavailableDates = new List<DateTime>();

		for (var currentDate = startDate; currentDate <= endDate; currentDate = currentDate.AddDays(1))
		{
			var dayAppointments = existingAppointments
				.Where(a => a.StartTime.Date == currentDate)
				.ToList();

			var dayAbsences = absences
				.Where(a => a.StartDate < currentDate.AddDays(1) && a.EndDate > currentDate)
				.Select(a => new AbsenceWindow(a.StartDate, a.EndDate))
				.ToList();

			if (!HasAvailableSlot(currentDate, durationMinutes, dayAppointments, dayAbsences))
			{
				unavailableDates.Add(currentDate);
			}
		}

		await Send.OkAsync(unavailableDates, cancellation: ct);
	}

	private static bool HasAvailableSlot(
		DateTime currentDate,
		double durationMinutes,
		List<AppointmentWindow> dayAppointments,
		List<AbsenceWindow> dayAbsences)
	{
		foreach (var currentSlot in SchedulingWindows.EnumerateSlotStarts(durationMinutes))
		{
			var slotStartTime = currentDate.Add(currentSlot);
			var slotEndTime = slotStartTime.AddMinutes(durationMinutes);

			var hasAppointmentOverlap = dayAppointments.Any(a =>
				a.StartTime < slotEndTime && a.EndTime > slotStartTime);

			var hasAbsenceOverlap = dayAbsences.Any(a =>
				a.StartDate < slotEndTime && a.EndDate > slotStartTime);

			if (!hasAppointmentOverlap && !hasAbsenceOverlap)
			{
				return true;
			}
		}

		return false;
	}
}
