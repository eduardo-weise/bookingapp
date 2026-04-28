using BookingApp.API.Extentions;
using BookingApp.Domain.Entities;
using BookingApp.Domain.Exceptions;
using BookingApp.Infrastructure.Data;
using FastEndpoints;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Scheduling.GetAvailableSlots;

public sealed record GetAvailableSlotsRequest(DateTime Date, Guid ServiceId);

public sealed class GetAvailableSlotsValidator : Validator<GetAvailableSlotsRequest>
{
	public GetAvailableSlotsValidator()
	{
		RuleFor(x => x.Date).NotEmpty();
		RuleFor(x => x.ServiceId).NotEmpty();
	}
}

public sealed class GetAvailableSlotsEndpoint(ApplicationDbContext dbContext)
	: Endpoint<GetAvailableSlotsRequest, List<TimeSpan>>
{
	public override void Configure()
	{
		Get("/appointments/available-slots");
		AllowAnonymous();
		Tags("Scheduling");
		Options(x => x.WithName("GetAvailableSlots"));
	}

	public override async Task HandleAsync(GetAvailableSlotsRequest req, CancellationToken ct)
	{
		var targetDate = req.Date.EnsureUtcDate();
		var targetDayEnd = targetDate.AddDays(1);

		var absences = await dbContext.AbsenceDays
			.AsNoTracking()
			.Where(a => a.StartDate < targetDayEnd && a.EndDate > targetDate)
			.ToListAsync(ct);

		var service = await dbContext.Services
			.AsNoTracking()
			.SingleOrDefaultAsync(s => s.Id == req.ServiceId, ct);

		if (service is null)
			throw new NotFoundException("Serviço não encontrado.");

		var durationMinutes = service.DefaultDuration.TotalMinutes;

		var startBusinessHours = new TimeSpan(9, 0, 0);
		var endBusinessHours = new TimeSpan(18, 0, 0);

		var existingAppointments = await dbContext.Appointments
			.AsNoTracking()
			.Where(a => a.Status == AppointmentStatus.Scheduled && a.StartTime.Date == targetDate)
			.OrderBy(a => a.StartTime)
			.ToListAsync(ct);

		var availableSlots = new List<TimeSpan>();
		var currentSlot = startBusinessHours;

		while (currentSlot.Add(TimeSpan.FromMinutes(durationMinutes)) <= endBusinessHours)
		{
			var slotStartTime = targetDate.Add(currentSlot);
			var slotEndTime = slotStartTime.AddMinutes(durationMinutes);

			var hasOverlap = existingAppointments.Any(a => a.StartTime < slotEndTime && a.EndTime > slotStartTime);
			var hasAbsenceOverlap = absences.Any(a => a.StartDate < slotEndTime && a.EndDate > slotStartTime);

			if (!hasOverlap && !hasAbsenceOverlap)
			{
				availableSlots.Add(currentSlot);
			}

			currentSlot = currentSlot.Add(TimeSpan.FromMinutes(30));
		}

		await Send.OkAsync(availableSlots, cancellation: ct);
	}
}
