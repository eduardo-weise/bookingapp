using System.Security.Claims;
using BookingApp.Domain.Exceptions;
using BookingApp.Infrastructure.Data;
using FastEndpoints;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Payments.PayDebtBalance;

public sealed record PayDebtBalanceRequest(Guid DebtId);

public sealed class PayDebtBalanceEndpoint(ApplicationDbContext dbContext)
	: Endpoint<PayDebtBalanceRequest>
{
	public override void Configure()
	{
		Post("/payments/debts/{id:guid}/pay");
		Tags("Payments");
		Options(x => x.WithName("PayDebtBalance"));
	}

	public override async Task HandleAsync(PayDebtBalanceRequest req, CancellationToken ct)
	{
		var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
		if (!Guid.TryParse(userIdString, out var clientId))
		{
			await Send.UnauthorizedAsync(ct);
			return;
		}

		var debtId = Route<Guid>("id");

		var debt = await dbContext.DebtBalances
			.SingleOrDefaultAsync(d => d.Id == debtId, ct);

		if (debt is null)
			throw new NotFoundException("Cobrança não encontrada.");

		if (debt.ClientId != clientId)
			throw new UnauthorizedAccessException("Este débito não pertence a você.");

		debt.MarkAsPaid();

		await dbContext.SaveChangesAsync(ct);

		await Send.NoContentAsync(ct);
	}
}
