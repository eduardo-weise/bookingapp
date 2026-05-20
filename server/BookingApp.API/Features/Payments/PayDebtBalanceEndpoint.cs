using System.Security.Claims;
using BookingApp.Domain.Entities;
using BookingApp.Domain.Events;
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
		if (!Guid.TryParse(userIdString, out var authenticatedUserId))
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

		var paidDebts = debts.Where(d => d.Status == DebtStatus.Pending).ToList();
		foreach (var debt in paidDebts)
		{
			debt.MarkAsPaid();
		}

		await dbContext.SaveChangesAsync(ct);

		if (paidDebts.Count > 0)
		{
			var payerRole = User.IsInRole("Admin") || User.IsInRole("Manager")
				? (User.IsInRole("Admin") ? "Admin" : "Manager")
				: "Client";
			var totalAmount = paidDebts.Sum(d => d.Amount);
			var paidIds = paidDebts.Select(d => d.Id).ToList();

			await new DebtPaid(req.ClientId, authenticatedUserId, payerRole, paidIds, totalAmount).PublishAsync(cancellation: ct);
		}

		await Send.NoContentAsync(ct);
	}
}
