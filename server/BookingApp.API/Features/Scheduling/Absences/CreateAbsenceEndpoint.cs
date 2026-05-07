using BookingApp.API.Extentions;
using BookingApp.Domain.Entities;
using BookingApp.Infrastructure.Data;
using BookingApp.Infrastructure.Settings.Authentication;
using FastEndpoints;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Scheduling.CreateAbsence;

public sealed record CreateAbsenceRequest(DateTime StartDate, DateTime EndDate);
public sealed record CreateAbsenceResponse(Guid Id, DateTime StartDate, DateTime EndDate);

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
	: Endpoint<CreateAbsenceRequest, CreateAbsenceResponse>
{
	public override void Configure()
	{
		Post("/absences");
		Policies(UserPolicy.AdminOrManager);
		Tags("Absences");
		Options(x => x.WithName("CreateAbsence"));
	}

	public override async Task HandleAsync(CreateAbsenceRequest req, CancellationToken ct)
	{
		var start = req.StartDate.EnsureUtc();
		var end = req.EndDate.EnsureUtc();

		if (end < start)
		{
			AddError("A data final deve ser igual ou posterior à data inicial.");
			await Send.ErrorsAsync(cancellation: ct);
			return;
		}

		var hasOverlap = await dbContext.AbsenceDays
			.AsNoTracking()
			.AnyAsync(a => a.StartDate < end && a.EndDate > start, ct);

		if (hasOverlap)
		{
			AddError("Já existe uma ausência registrada nesse período.");
			await Send.ErrorsAsync(cancellation: ct);
			return;
		}

		var absence = new AbsenceDay(start, end);

		await dbContext.AbsenceDays.AddAsync(absence, ct);
		await dbContext.SaveChangesAsync(ct);

		var response = new CreateAbsenceResponse(absence.Id, absence.StartDate, absence.EndDate);

		await Send.CreatedAtAsync<CreateAbsenceEndpoint>(null, response, cancellation: ct);
	}
}
