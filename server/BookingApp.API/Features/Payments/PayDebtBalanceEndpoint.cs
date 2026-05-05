using System.Security.Claims;
using BookingApp.Domain.Entities;
using BookingApp.Infrastructure.Data;
using FastEndpoints;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Payments.PayDebtBalance;

public sealed record PayDebtBalanceRequest(Guid ClientId, List<Guid> DebtIds);

public sealed class PayDebtBalanceEndpoint(ApplicationDbContext dbContext)
	: Endpoint<PayDebtBalanceRequest>
{
	public override void Configure()
	{
		Post("/payments/debts/pay");
		Policies("All");
		Tags("Payments");
		Options(x => x.WithName("PayDebtBalances"));
	}

	public override async Task HandleAsync(PayDebtBalanceRequest req, CancellationToken ct)
	{
		var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
		if (!Guid.TryParse(userIdString, out var _))
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

		foreach (var debt in debts.Where(d => d.Status == DebtStatus.Pending))
		{
			debt.MarkAsPaid();
		}

		await dbContext.SaveChangesAsync(ct);
		await Send.NoContentAsync(ct);
	}
}
