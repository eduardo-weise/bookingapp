using BookingApp.Domain.Entities;
using BookingApp.Infrastructure.Data;
using FastEndpoints;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Scheduling.CreateAbsence;

public sealed record CreateAbsenceRequest(DateTime StartDate, DateTime EndDate);

public sealed class CreateAbsenceValidator : Validator<CreateAbsenceRequest>
{
	public CreateAbsenceValidator()
	{
		RuleFor(x => x.StartDate).NotEmpty();
		RuleFor(x => x.EndDate)
			.NotEmpty()
			.GreaterThanOrEqualTo(x => x.StartDate)
			.WithMessage("A data final deve ser igual ou posterior à data inicial.");
	}
}

public sealed class CreateAbsenceEndpoint(ApplicationDbContext dbContext)
	: Endpoint<CreateAbsenceRequest>
{
	public override void Configure()
	{
		Post("/absences");
		Policies("AdminOrManager");
		Tags("Scheduling");
		Options(x => x.WithName("CreateAbsence"));
	}

	public override async Task HandleAsync(CreateAbsenceRequest req, CancellationToken ct)
	{
		var start = req.StartDate.Date;
		var end = req.EndDate.Date;

		// Generate all dates in the range
		var dates = Enumerable
			.Range(0, (end - start).Days + 1)
			.Select(offset => start.AddDays(offset))
			.ToList();

		// Skip dates that are already registered
		var existing = await dbContext.AbsenceDays
			.AsNoTracking()
			.Where(a => a.Date >= start && a.Date <= end)
			.Select(a => a.Date)
			.ToListAsync(ct);

		var toInsert = dates
			.Where(d => !existing.Contains(d))
			.Select(d => new AbsenceDay(d))
			.ToList();

		if (toInsert.Count > 0)
		{
			await dbContext.AbsenceDays.AddRangeAsync(toInsert, ct);
			await dbContext.SaveChangesAsync(ct);
		}

		await Send.NoContentAsync(ct);
	}
}
