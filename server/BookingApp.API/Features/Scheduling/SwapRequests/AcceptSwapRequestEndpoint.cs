using System.Security.Claims;
using BookingApp.Domain.Exceptions;
using BookingApp.Infrastructure.Data;
using BookingApp.Infrastructure.Settings.Authentication;
using FastEndpoints;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Scheduling.AcceptSwapRequest;

public sealed record AcceptSwapRequestRequest(Guid Id);

public sealed class AcceptSwapRequestEndpoint(ApplicationDbContext dbContext)
	: Endpoint<AcceptSwapRequestRequest>
{
	public override void Configure()
	{
		Post("/appointments/swaps/{id:guid}/accept");
		Policies(UserPolicy.All);
		Tags("SwapRequest");
		Options(x => x.WithName("AcceptSwapRequest"));
	}

	public override async Task HandleAsync(AcceptSwapRequestRequest req, CancellationToken ct)
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
			throw new UnauthorizedAccessException("Você não tem permissão para aceitar esta solicitação.");

		var sourceAppt = await dbContext.Appointments
			.SingleOrDefaultAsync(a => a.Id == swap.RequesterAppointmentId, ct)
			?? throw new NotFoundException("Agendamento de origem não encontrado.");

		swap.Accept();

		// Swap ownership
		var sourceOwner = sourceAppt.ClientId;
		var targetOwner = targetAppt.ClientId;

		sourceAppt.ChangeClient(targetOwner);
		targetAppt.ChangeClient(sourceOwner);

		await dbContext.SaveChangesAsync(ct);

		await Send.NoContentAsync(ct);
	}
}
