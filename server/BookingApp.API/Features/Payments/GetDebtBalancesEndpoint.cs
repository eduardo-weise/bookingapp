using System.Security.Claims;
using BookingApp.Domain.Entities;
using BookingApp.Infrastructure.Data;
using BookingApp.Infrastructure.Settings.Authentication;
using FastEndpoints;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Payments.GetDebtBalances;

public sealed record DebtBalanceResponse(
	Guid Id, 
	Guid ClientId,
	string ClientName,
	Guid AppointmentId, 
	string ServiceName,
	DateTime AppointmentDate,
	decimal Amount, 
	DebtStatus Status, 
	DateTime CreatedAt
);

public sealed class GetDebtBalancesEndpoint(ApplicationDbContext dbContext)
	: EndpointWithoutRequest<List<DebtBalanceResponse>>
{
	public override void Configure()
	{
		Get("/payments/debts");
		Policies(UserPolicy.All);
		Tags("Payments");
		Options(x => x.WithName("GetDebtBalances"));
	}

	public override async Task HandleAsync(CancellationToken ct)
	{
		var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
		if (!Guid.TryParse(userIdString, out var clientId))
		{
			await Send.UnauthorizedAsync(ct);
			return;
		}

		var isAdminOrManager = User.IsInRole("Admin") || User.IsInRole("Manager");

		var query = from d in dbContext.DebtBalances.AsNoTracking()
					join u in dbContext.Users on d.ClientId equals u.Id
					join a in dbContext.Appointments on d.AppointmentId equals a.Id
					join s in dbContext.Services on a.ServiceId equals s.Id
					orderby d.CreatedAt descending
					select new { d, u, a, s };

		if (!isAdminOrManager)
		{
			query = query.Where(q => q.d.ClientId == clientId);
		}
		
		var debts = await query
			.Where(q => q.d.Status == DebtStatus.Pending)
			.Select(q => new DebtBalanceResponse(
				q.d.Id, 
				q.d.ClientId,
				q.u.Name ?? q.u.Email,
				q.d.AppointmentId, 
				q.s.Name,
				q.a.StartTime,
				q.d.Amount, 
				q.d.Status, 
				q.d.CreatedAt))
			.ToListAsync(ct);

		await Send.OkAsync(debts, cancellation: ct);
	}
}
