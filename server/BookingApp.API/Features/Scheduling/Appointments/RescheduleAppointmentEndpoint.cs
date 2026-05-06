using System.Security.Claims;
using BookingApp.API.Extentions;
using BookingApp.Domain.Entities;
using BookingApp.Domain.Exceptions;
using BookingApp.Infrastructure.Data;
using BookingApp.Infrastructure.Settings.Authentication;
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
	: Endpoint<RescheduleAppointmentRequest>
{
	public override void Configure()
	{
		Post("/appointments/{id:guid}/reschedule");
		Policies(UserPolicy.All);
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

		var appointment = await dbContext.Appointments
			.SingleOrDefaultAsync(a => a.Id == req.Id, ct)
			?? throw new NotFoundException("Agendamento não encontrado.");

		EnsureUserCanReschedule(appointment, authenticatedUserId, isAdminOrManager);

		var hoursUntilStart = (appointment.StartTime - DateTime.UtcNow).TotalHours;

		// Clients: block if < 1h
		if (!isAdminOrManager && hoursUntilStart < 1)
			throw new InvalidOperationException("Reagendamento não permitido com menos de 1h de antecedência.");

		var isLateReschedule = hoursUntilStart < 24;

		var service = await dbContext.Services
			.AsNoTracking()
			.SingleOrDefaultAsync(s => s.Id == req.ServiceId, ct)
			?? throw new NotFoundException("Serviço não encontrado.");

		var client = await dbContext.Users
			.AsNoTracking()
			.SingleOrDefaultAsync(u => u.Id == appointment.ClientId, ct)
			?? throw new NotFoundException("Cliente não encontrado.");

		var duration = service.DefaultDuration + client.ExtraServiceDuration;
		var startTime = req.StartTime.EnsureUtc();
		var endTime = startTime.Add(duration);

		await EnsureNoSchedulingConflicts(req.Id, startTime, endTime, ct);

		// Update existing appointment and mark as rescheduled
		appointment.Reschedule(req.ServiceId, startTime, endTime, allowLateReschedule: true);

		// Apply late reschedule fee if applicable
		var shouldApplyFee = isLateReschedule && (!isAdminOrManager || req.ApplyLateRescheduleFee == true);

		if (shouldApplyFee)
		{
			var hasPendingDebt = await dbContext.DebtBalances
				.AsNoTracking()
				.AnyAsync(d => d.AppointmentId == appointment.Id && d.Status == DebtStatus.Pending, ct);

			if (!hasPendingDebt)
			{
				var feeAmount = service.Price * 0.15m;
				await dbContext.DebtBalances.AddAsync(
					new DebtBalance(appointment.ClientId, appointment.Id, feeAmount),
					ct);
			}
		}

		await dbContext.SaveChangesAsync(ct);
		await Send.NoContentAsync(ct);
	}

	private static void EnsureUserCanReschedule(Appointment appointment, Guid authenticatedUserId, bool isAdminOrManager)
	{
		if (!isAdminOrManager && appointment.ClientId != authenticatedUserId)
			throw new UnauthorizedAccessException("Este agendamento não pertence a você.");
	}

	private async Task EnsureNoSchedulingConflicts(Guid appointmentId, DateTime startTime, DateTime endTime, CancellationToken ct)
	{
		var hasAbsenceConflict = await dbContext.AbsenceDays
			.AsNoTracking()
			.AnyAsync(a => a.StartDate < endTime && a.EndDate > startTime, ct);

		if (hasAbsenceConflict)
			throw new ConflictException("Não é possível agendar em um dia de ausência programada.");

		var hasOverlap = await dbContext.Appointments
			.AsNoTracking()
			.AnyAsync(a => a.Id != appointmentId &&
						   (a.Status == AppointmentStatus.Scheduled || a.Status == AppointmentStatus.Rescheduled) &&
						   a.StartTime < endTime && a.EndTime > startTime, ct);

		if (hasOverlap)
			throw new ConflictException("Horário não disponível.");
	}
}
