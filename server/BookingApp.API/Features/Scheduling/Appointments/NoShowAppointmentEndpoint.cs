using System.Security.Claims;
using BookingApp.Domain.Entities;
using BookingApp.Domain.Exceptions;
using BookingApp.Infrastructure.Data;
using BookingApp.Infrastructure.Settings.Authentication;
using FastEndpoints;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Scheduling.Appointments;

public sealed record NoShowAppointmentRequest(Guid Id, bool ApplyNoShowFee = true);

public sealed class NoShowAppointmentEndpoint(ApplicationDbContext dbContext)
	: Endpoint<NoShowAppointmentRequest>
{
	public override void Configure()
	{
		Post("/appointments/{id:guid}/noshow");
		Policies(UserPolicy.All);
		Tags("Application");
		Options(x => x.WithName("NoShowAppointment"));
	}

	public override async Task HandleAsync(NoShowAppointmentRequest req, CancellationToken ct)
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

		var isOwnAppointment = appointment.ClientId == authenticatedUserId;
		if (!isAdminOrManager && !isOwnAppointment)
			throw new UnauthorizedAccessException("Este agendamento não pertence a você.");

		if (!appointment.IsActive())
			throw new InvalidOperationException("Somente agendamentos ativos podem ser marcados como no-show.");

		if (DateTime.UtcNow <= appointment.StartTime)
			throw new InvalidOperationException("Não é possível marcar no-show antes do horário do agendamento.");

		appointment.NoShow();

		if (req.ApplyNoShowFee)
		{
			var service = await dbContext.Services
				.AsNoTracking()
				.SingleOrDefaultAsync(s => s.Id == appointment.ServiceId, ct);

			if (service is null)
				throw new NotFoundException("Serviço não encontrado para aplicar multa de no-show.");

			var penaltyAmount = service.Price * 0.5m;
			var description = $"Multa por ausência (no-show) em agendamento com {service.Name}";

			await dbContext.DebtBalances.AddAsync(
				new DebtBalance(appointment.ClientId, appointment.Id, penaltyAmount, DebtType.NoShow, description, 50),
				ct);
		}

		await dbContext.SaveChangesAsync(ct);

		await Send.NoContentAsync(ct);
	}
}
