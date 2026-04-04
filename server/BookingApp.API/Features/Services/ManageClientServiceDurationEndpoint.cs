using BookingApp.Domain.Entities;
using BookingApp.Domain.Exceptions;
using BookingApp.Infrastructure.Data;
using FastEndpoints;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Services.ManageClientServiceDuration;

public sealed record ManageClientServiceDurationRequest(Guid ClientId, Guid ServiceId, TimeSpan Duration);

public sealed class ManageClientServiceDurationEndpoint(ApplicationDbContext dbContext)
	: Endpoint<ManageClientServiceDurationRequest>
{
	public override void Configure()
	{
		Post("/services/{serviceId:guid}/clients/{clientId:guid}/duration");
		Tags("Services");
		Options(x => x.WithName("ManageClientServiceDuration"));
	}

	public override async Task HandleAsync(ManageClientServiceDurationRequest req, CancellationToken ct)
	{
		var service = await dbContext.Services
			.SingleOrDefaultAsync(s => s.Id == req.ServiceId, ct)
			?? throw new NotFoundException("Serviço não encontrado.");

		var existingDuration = await dbContext.ClientServiceDurations
			.SingleOrDefaultAsync(c => c.ClientId == req.ClientId && c.ServiceId == req.ServiceId, ct);

		if (existingDuration is not null)
		{
			existingDuration.UpdateDuration(req.Duration);
		}
		else
		{
			var newDuration = new ClientServiceDuration(req.ClientId, req.ServiceId, req.Duration);
			await dbContext.ClientServiceDurations.AddAsync(newDuration, ct);
		}

		await dbContext.SaveChangesAsync(ct);

		await Send.NoContentAsync(ct);
	}
}
