using BookingApp.Domain.Exceptions;
using BookingApp.Infrastructure.Data;
using FastEndpoints;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Scheduling.DeleteAbsence;

public sealed record DeleteAbsenceRequest(Guid Id);

public sealed class DeleteAbsenceEndpoint(ApplicationDbContext dbContext)
	: Endpoint<DeleteAbsenceRequest>
{
	public override void Configure()
	{
		Delete("/absences/{id:guid}");
		Policies("AdminOrManager");
		Tags("Scheduling");
		Options(x => x.WithName("DeleteAbsence"));
	}

	public override async Task HandleAsync(DeleteAbsenceRequest req, CancellationToken ct)
	{
		var absence = await dbContext.AbsenceDays
			.SingleOrDefaultAsync(a => a.Id == req.Id, ct);

		if (absence is null)
			throw new NotFoundException("Ausência não encontrada.");

		dbContext.AbsenceDays.Remove(absence);
		await dbContext.SaveChangesAsync(ct);

		await Send.NoContentAsync(ct);
	}
}
