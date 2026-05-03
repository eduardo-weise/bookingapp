using System.Security.Claims;
using BookingApp.API.Extentions;
using BookingApp.Domain.Entities;
using BookingApp.Domain.Exceptions;
using BookingApp.Infrastructure.Data;
using FastEndpoints;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Scheduling.RescheduleAppointment;

public sealed record RescheduleAppointmentRequest(
	Guid Id,
	Guid ServiceId,
	DateTime StartTime,
	bool? ApplyLateRescheduleFee = null
);

public sealed class RescheduleAppointmentValidator : Validator<RescheduleAppointmentRequest>
{
	public RescheduleAppointmentValidator()
	{
		RuleFor(x => x.Id).NotEmpty();
		RuleFor(x => x.ServiceId).NotEmpty();
		RuleFor(x => x.StartTime).NotEmpty();
	}
}

public sealed class RescheduleAppointmentEndpoint(ApplicationDbContext dbContext)
	: Endpoint<RescheduleAppointmentRequest, object>
{
	public override void Configure()
	{
		Post("/appointments/{id:guid}/reschedule");
		Policies("All");
		Tags("Application");
		Options(x => x.WithName("RescheduleAppointment"));
	}

	public override async Task HandleAsync(RescheduleAppointmentRequest req, CancellationToken ct)
	{
		var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
		if (!Guid.TryParse(userIdString, out var authenticatedUserId))
		{
			await Send.UnauthorizedAsync(ct);
			return;
		}

		var isAdminOrManager = User.IsInRole("Admin") || User.IsInRole("Manager");

		// Load old appointment
		var oldAppointment = await dbContext.Appointments
			.SingleOrDefaultAsync(a => a.Id == req.Id, ct);

		if (oldAppointment is null)
			throw new NotFoundException("Agendamento não encontrado.");

		if (!isAdminOrManager && oldAppointment.ClientId != authenticatedUserId)
			throw new UnauthorizedAccessException("Este agendamento não pertence a você.");

		var hoursUntilStart = (oldAppointment.StartTime - DateTime.UtcNow).TotalHours;

		// Clients: block if < 1h
		if (!isAdminOrManager && hoursUntilStart < 1)
			throw new InvalidOperationException("Reagendamento não permitido com menos de 1h de antecedência.");

		var isLateReschedule = hoursUntilStart < 24;

		// Mark old appointment as rescheduled
		oldAppointment.MarkAsRescheduled(allowLateReschedule: true);

		// Load service for new appointment
		var service = await dbContext.Services
			.AsNoTracking()
			.SingleOrDefaultAsync(s => s.Id == req.ServiceId, ct);

		if (service is null)
			throw new NotFoundException("Serviço não encontrado.");

		var clientDuration = await dbContext.ClientServiceDurations
			.AsNoTracking()
			.SingleOrDefaultAsync(c => c.ClientId == oldAppointment.ClientId && c.ServiceId == req.ServiceId, ct);

		var duration = clientDuration?.Duration ?? service.DefaultDuration;
		var startTime = req.StartTime.EnsureUtc();
		var endTime = startTime.Add(duration);

		// Check conflicts for new slot
		var hasAbsenceConflict = await dbContext.AbsenceDays
			.AsNoTracking()
			.AnyAsync(a => a.StartDate < endTime && a.EndDate > startTime, ct);

		if (hasAbsenceConflict)
			throw new ConflictException("Não é possível agendar em um dia de ausência programada.");

		var hasOverlap = await dbContext.Appointments
			.AsNoTracking()
			.AnyAsync(a => a.Id != req.Id &&
						   a.Status == AppointmentStatus.Scheduled &&
						   a.StartTime < endTime && a.EndTime > startTime, ct);

		if (hasOverlap)
			throw new ConflictException("Horário não disponível.");

		// Create new appointment
		var newAppointment = new Appointment(oldAppointment.ClientId, req.ServiceId, startTime, endTime);
		await dbContext.Appointments.AddAsync(newAppointment, ct);

		// Apply late reschedule fee if applicable
		var shouldApplyFee = false;
		if (isLateReschedule)
		{
			shouldApplyFee = isAdminOrManager
				? req.ApplyLateRescheduleFee ?? false
				: true;
		}

		if (shouldApplyFee)
		{
			var hasPendingDebt = await dbContext.DebtBalances
				.AsNoTracking()
				.AnyAsync(d => d.AppointmentId == oldAppointment.Id && d.Status == DebtStatus.Pending, ct);

			if (!hasPendingDebt)
			{
				var feeAmount = service.Price * 0.15m;
				await dbContext.DebtBalances.AddAsync(
					new DebtBalance(oldAppointment.ClientId, oldAppointment.Id, feeAmount),
					ct);
			}
		}

		await dbContext.SaveChangesAsync(ct);

		await Send.CreatedAtAsync<RescheduleAppointmentEndpoint>(
			null,
			new { Id = newAppointment.Id },
			cancellation: ct);
	}
}
