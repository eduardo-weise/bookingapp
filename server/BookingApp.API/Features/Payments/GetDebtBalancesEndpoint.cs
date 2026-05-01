using System.Security.Claims;
using BookingApp.Domain.Entities;
using BookingApp.Infrastructure.Data;
using FastEndpoints;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Payments.GetDebtBalances;

public sealed record DebtBalanceResponse(Guid Id, Guid AppointmentId, decimal Amount, DebtStatus Status, DateTime CreatedAt);

public sealed class GetDebtBalancesEndpoint(ApplicationDbContext dbContext)
	: EndpointWithoutRequest<List<DebtBalanceResponse>>
{
	public override void Configure()
	{
		Get("/payments/debts");
		Tags("Payments");
		Options(x => x.WithName("GetDebtBalances"));
		Policies("All");
	}

	public override async Task HandleAsync(CancellationToken ct)
	{
		var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
		if (!Guid.TryParse(userIdString, out var clientId))
		{
			await Send.UnauthorizedAsync(ct);
			return;
		}

		var debts = await dbContext.DebtBalances
			.AsNoTracking()
			.Where(d => d.ClientId == clientId)
			.OrderByDescending(d => d.CreatedAt)
			.Select(d => new DebtBalanceResponse(d.Id, d.AppointmentId, d.Amount, d.Status, d.CreatedAt))
			.ToListAsync(ct);

		await Send.OkAsync(debts, cancellation: ct);
	}
}
