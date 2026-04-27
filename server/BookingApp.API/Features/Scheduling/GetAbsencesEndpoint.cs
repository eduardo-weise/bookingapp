using BookingApp.Domain.Entities;
using BookingApp.Domain.Exceptions;
using BookingApp.Infrastructure.Data;
using FastEndpoints;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Scheduling.GetAbsences;

public sealed record AbsenceDayDto(Guid Id, DateTime Date);

public sealed record GetAbsencesRequest(bool Future = true, int Page = 1, int PageSize = 10);

public sealed class GetAbsencesEndpoint(ApplicationDbContext dbContext)
	: Endpoint<GetAbsencesRequest, List<AbsenceDayDto>>
{
	public override void Configure()
	{
		Get("/absences");
		Policies("AdminOrManager");
		Tags("Scheduling");
		Options(x => x.WithName("GetAbsences"));
	}

	public override async Task HandleAsync(GetAbsencesRequest req, CancellationToken ct)
	{
		var today = DateTime.UtcNow.Date;

		var query = dbContext.AbsenceDays
			.AsNoTracking()
			.Where(a => req.Future ? a.Date >= today : a.Date < today)
			.OrderBy(a => req.Future ? a.Date : default)
			.ThenByDescending(a => req.Future ? default : a.Date);

		var items = await query
			.Skip((req.Page - 1) * req.PageSize)
			.Take(req.PageSize)
			.Select(a => new AbsenceDayDto(a.Id, a.Date))
			.ToListAsync(ct);

		await Send.OkAsync(items, cancellation: ct);
	}
}
