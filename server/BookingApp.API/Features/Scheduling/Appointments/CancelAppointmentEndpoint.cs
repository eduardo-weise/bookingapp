using System.Security.Claims;
using BookingApp.Domain.Exceptions;
using BookingApp.Infrastructure.Data;
using FastEndpoints;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Scheduling.CancelAppointment;

public sealed record CancelAppointmentRequest(Guid Id);

public sealed class CancelAppointmentEndpoint(ApplicationDbContext dbContext)
	: Endpoint<CancelAppointmentRequest>
{
	public override void Configure()
	{
		Post("/appointments/{id:guid}/cancel");
		Policies("All");
		Tags("Application");
		Options(x => x.WithName("CancelAppointment"));
	}

	public override async Task HandleAsync(CancelAppointmentRequest req, CancellationToken ct)
	{
		var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
		if (!Guid.TryParse(userIdString, out var clientId))
		{
			await Send.UnauthorizedAsync(ct);
			return;
		}

		var appointment = await dbContext.Appointments
			.SingleOrDefaultAsync(a => a.Id == req.Id, ct);

		if (appointment is null)
			throw new NotFoundException("Agendamento não encontrado.");

		if (appointment.ClientId != clientId)
			throw new UnauthorizedAccessException("Este agendamento não pertence a você.");

		appointment.Cancel();

		await dbContext.SaveChangesAsync(ct);

		await Send.NoContentAsync(ct);
	}
}
