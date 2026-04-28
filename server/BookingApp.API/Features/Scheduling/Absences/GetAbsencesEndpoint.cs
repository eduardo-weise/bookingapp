using BookingApp.Infrastructure.Data;
using FastEndpoints;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Scheduling.GetAbsences;

public sealed record AbsenceDayDto(Guid Id, DateTime StartDate, DateTime EndDate);

public sealed class GetAbsencesRequest
{
	[QueryParam] public bool Future { get; set; } = true;
	[QueryParam] public int Page { get; set; } = 1;
	[QueryParam] public int PageSize { get; set; } = 10;
}

public sealed class GetAbsencesEndpoint(ApplicationDbContext dbContext)
	: Endpoint<GetAbsencesRequest, List<AbsenceDayDto>>
{
	public override void Configure()
	{
		Get("/absences");
		Policies("AdminOrManager");
		Tags("Absences");
		Options(x => x.WithName("GetAbsences"));
	}

	public override async Task HandleAsync(GetAbsencesRequest req, CancellationToken ct)
	{
		var today = DateTime.SpecifyKind(DateTime.UtcNow.Date, DateTimeKind.Unspecified);

		var query = dbContext.AbsenceDays
			.AsNoTracking()
			.Where(a => req.Future ? a.EndDate >= today : a.EndDate < today);

		query = req.Future
			? query.OrderBy(a => a.StartDate)
			: query.OrderByDescending(a => a.StartDate);

		var items = await query
			.Skip((req.Page - 1) * req.PageSize)
			.Take(req.PageSize)
			.Select(a => new AbsenceDayDto(a.Id, a.StartDate, a.EndDate))
			.ToListAsync(ct);

		await Send.OkAsync(items, cancellation: ct);
	}
}
