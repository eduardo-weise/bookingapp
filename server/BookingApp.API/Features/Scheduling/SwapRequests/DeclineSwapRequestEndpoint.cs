using System.Security.Claims;
using BookingApp.Domain.Exceptions;
using BookingApp.Infrastructure.Data;
using BookingApp.Infrastructure.Settings.Authentication;
using FastEndpoints;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Scheduling.DeclineSwapRequest;

public sealed record DeclineSwapRequestRequest(Guid Id);

public sealed class DeclineSwapRequestEndpoint(ApplicationDbContext dbContext)
	: Endpoint<DeclineSwapRequestRequest>
{
	public override void Configure()
	{
		Post("/appointments/swaps/{id:guid}/decline");
		Policies(UserPolicy.All);
		Tags("SwapRequest");
		Options(x => x.WithName("DeclineSwapRequest"));
	}

	public override async Task HandleAsync(DeclineSwapRequestRequest req, CancellationToken ct)
	{
		var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
		if (!Guid.TryParse(userIdString, out var clientId))
		{
			await Send.UnauthorizedAsync(ct);
			return;
		}

		var swap = await dbContext.SwapRequests
			.SingleOrDefaultAsync(s => s.Id == req.Id, ct)
			?? throw new NotFoundException("Solicitação não encontrada.");

		var targetAppt = await dbContext.Appointments
			.SingleOrDefaultAsync(a => a.Id == swap.TargetAppointmentId, ct)
			?? throw new NotFoundException("Agendamento de destino não encontrado.");

		if (targetAppt.ClientId != clientId)
		{
			throw new UnauthorizedAccessException("Você não tem permissão para recusar esta solicitação.");
		}

		swap.Decline();

		await dbContext.SaveChangesAsync(ct);

		await Send.NoContentAsync(ct);
	}
}
