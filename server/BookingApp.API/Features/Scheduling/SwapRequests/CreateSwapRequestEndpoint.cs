using System.Security.Claims;
using BookingApp.Domain.Entities;
using BookingApp.Domain.Exceptions;
using BookingApp.Infrastructure.Data;
using FastEndpoints;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Scheduling.CreateSwapRequest;

public sealed record CreateSwapRequestRequest(Guid RequesterAppointmentId, Guid TargetAppointmentId);

public sealed class CreateSwapRequestEndpoint(ApplicationDbContext dbContext)
	: Endpoint<CreateSwapRequestRequest, Guid>
{
	public override void Configure()
	{
		Post("/appointments/swaps");
		Policies("All");
		Tags("SwapRequest");
		Options(x => x.WithName("CreateSwapRequest"));
	}

	public override async Task HandleAsync(CreateSwapRequestRequest req, CancellationToken ct)
	{
		var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
		if (!Guid.TryParse(userIdString, out var clientId))
		{
			await Send.UnauthorizedAsync(ct);
			return;
		}

		var requesterAppt = await dbContext.Appointments
			.SingleOrDefaultAsync(a => a.Id == req.RequesterAppointmentId, ct);

		if (requesterAppt is null ||
			requesterAppt.ClientId != clientId ||
			requesterAppt.Status != AppointmentStatus.Scheduled)
		{
			throw new ConflictException("Agendamento de origem inválido ou não pertence a você.");
		}

		var targetAppt = await dbContext.Appointments
			.SingleOrDefaultAsync(a => a.Id == req.TargetAppointmentId, ct);

		if (targetAppt is null || targetAppt.Status != AppointmentStatus.Scheduled)
		{
			throw new ConflictException("Agendamento de destino inválido ou indisponível.");
		}

		var swapRequest = new SwapRequest(req.RequesterAppointmentId, req.TargetAppointmentId, TimeSpan.FromHours(24));

		await dbContext.SwapRequests.AddAsync(swapRequest, ct);
		await dbContext.SaveChangesAsync(ct);

		await Send.CreatedAtAsync<CreateSwapRequestEndpoint>(null, swapRequest.Id, cancellation: ct);
	}
}
