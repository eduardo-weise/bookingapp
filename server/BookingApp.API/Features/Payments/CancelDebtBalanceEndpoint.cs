using System.Security.Claims;
using BookingApp.Domain.Entities;
using BookingApp.Infrastructure.Data;
using BookingApp.Infrastructure.Settings.Authentication;
using FastEndpoints;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Payments.CancelDebtBalance;

public sealed record CancelDebtBalanceRequest(Guid ClientId, List<Guid> DebtIds);

public sealed class CancelDebtBalanceEndpoint(ApplicationDbContext dbContext)
	: Endpoint<CancelDebtBalanceRequest>
{
	public override void Configure()
	{
		Post("/payments/debts/cancel");
		Policies(UserPolicy.AdminOrManager);
		Tags("Payments");
		Options(x => x.WithName("CancelDebtBalances"));
	}

	public override async Task HandleAsync(CancelDebtBalanceRequest req, CancellationToken ct)
	{
		var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
		if (!Guid.TryParse(userIdString, out var currentUserId))
		{
			await Send.UnauthorizedAsync(ct);
			return;
		}

		var debts = await dbContext.DebtBalances
			.Where(d => req.DebtIds.Contains(d.Id) && d.ClientId == req.ClientId)
			.ToListAsync(ct);

		if (debts.Count == 0)
		{
			await Send.NotFoundAsync(ct);
			return;
		}

		foreach (var debt in debts)
		{
			if (debt.Status == DebtStatus.Pending)
				debt.Cancel();
		}

		await dbContext.SaveChangesAsync(ct);
		await Send.NoContentAsync(ct);
	}
}
