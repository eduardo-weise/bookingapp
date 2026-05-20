using System.Security.Claims;
using BookingApp.Domain.Entities;
using BookingApp.Domain.Events;
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

		var canceledDebts = debts.Where(d => d.Status == DebtStatus.Pending).ToList();
		foreach (var debt in canceledDebts)
		{
			debt.Cancel();
		}

		await dbContext.SaveChangesAsync(ct);

		if (canceledDebts.Count > 0)
		{
			var totalCanceled = canceledDebts.Sum(d => d.Amount);
			var canceledIds = canceledDebts.Select(d => d.Id).ToList();
			await new DebtCanceled(req.ClientId, canceledIds, totalCanceled).PublishAsync(cancellation: ct);
		}

		await Send.NoContentAsync(ct);
	}
}
