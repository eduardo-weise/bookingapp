using System.Security.Claims;
using BookingApp.Domain.Entities;
using BookingApp.Domain.Exceptions;
using BookingApp.Infrastructure.Data;
using BookingApp.Infrastructure.Settings.Authentication;
using FastEndpoints;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Scheduling.CancelAppointment;

public sealed record CancelAppointmentRequest(Guid Id, bool? ApplyLateCancellationFee = null);

public sealed class CancelAppointmentEndpoint(ApplicationDbContext dbContext)
	: Endpoint<CancelAppointmentRequest>
{
	public override void Configure()
	{
		Post("/appointments/{id:guid}/cancel");
		Policies(UserPolicy.All);
		Tags("Application");
		Options(x => x.WithName("CancelAppointment"));
	}

	public override async Task HandleAsync(CancelAppointmentRequest req, CancellationToken ct)
	{
		var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
		if (!Guid.TryParse(userIdString, out var authenticatedUserId))
		{
			await Send.UnauthorizedAsync(ct);
			return;
		}

		var isAdminOrManager = User.IsInRole("Admin") || User.IsInRole("Manager");

		var appointment = await dbContext.Appointments
			.SingleOrDefaultAsync(a => a.Id == req.Id, ct);

		if (appointment is null)
			throw new NotFoundException("Agendamento não encontrado.");

		if (!isAdminOrManager && appointment.ClientId != authenticatedUserId)
			throw new UnauthorizedAccessException("Este agendamento não pertence a você.");

		var isLateCancellation = appointment.StartTime <= DateTime.UtcNow.AddHours(24);
		var shouldApplyFee = false;

		if (isLateCancellation)
		{
			shouldApplyFee = isAdminOrManager
				? req.ApplyLateCancellationFee ?? true
				: true;
		}

		appointment.Cancel(allowLateCancellation: isLateCancellation);

		if (shouldApplyFee)
		{
			var hasPendingDebt = await dbContext.DebtBalances
				.AsNoTracking()
				.AnyAsync(d => d.AppointmentId == appointment.Id && d.Status == DebtStatus.Pending, ct);

			if (!hasPendingDebt)
			{
				var service = await dbContext.Services
					.AsNoTracking()
					.SingleOrDefaultAsync(s => s.Id == appointment.ServiceId, ct);

				if (service is null)
					throw new NotFoundException("Serviço não encontrado para aplicar taxa de cancelamento.");

				var feeAmount = service.Price * 0.35m;
				await dbContext.DebtBalances.AddAsync(
					new DebtBalance(appointment.ClientId, appointment.Id, feeAmount),
					ct);
			}
		}

		await dbContext.SaveChangesAsync(ct);

		await Send.NoContentAsync(ct);
	}
}
