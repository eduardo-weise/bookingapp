using BookingApp.API.Extentions;
using BookingApp.API.Features.Scheduling.Appointments;
using BookingApp.Domain.Entities;
using BookingApp.Domain.Exceptions;
using BookingApp.Infrastructure.Data;
using BookingApp.Infrastructure.Settings.Authentication;
using FastEndpoints;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Scheduling.GetAvailableSlots;

public sealed record GetAvailableSlotsRequest(DateTime Date, Guid ServiceId, Guid? ClientId = null);

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
		Policies(UserPolicy.All);
		Tags("Application");
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

		var existingAppointments = await dbContext.Appointments
			.AsNoTracking()
			.Where(a => a.Status == AppointmentStatus.Scheduled && a.StartTime.Date == targetDate)
			.OrderBy(a => a.StartTime)
			.ToListAsync(ct);

		var availableSlots = new List<TimeSpan>();

		foreach (var currentSlot in SchedulingWindows.EnumerateSlotStarts(durationMinutes))
		{
			var slotStartTime = targetDate.Add(currentSlot);
			var slotEndTime = slotStartTime.AddMinutes(durationMinutes);

			var hasOverlap = existingAppointments.Any(a => a.StartTime < slotEndTime && a.EndTime > slotStartTime);
			var hasAbsenceOverlap = absences.Any(a => a.StartDate < slotEndTime && a.EndDate > slotStartTime);

			if (!hasOverlap && !hasAbsenceOverlap)
			{
				availableSlots.Add(currentSlot);
			}
		}

		await Send.OkAsync(availableSlots, cancellation: ct);
	}
}
