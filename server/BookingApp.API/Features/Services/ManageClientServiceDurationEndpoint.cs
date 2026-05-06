using BookingApp.Domain.Entities;
using BookingApp.Domain.Exceptions;
using BookingApp.Infrastructure.Data;
using BookingApp.Infrastructure.Settings.Authentication;
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
		Policies(UserPolicy.AdminOrManager);
		Tags("Services");
		Options(x => x.WithName("ManageClientServiceDuration"));
	}

	public override async Task HandleAsync(ManageClientServiceDurationRequest req, CancellationToken ct)
	{
		var client = await dbContext.Users
			.SingleOrDefaultAsync(u => u.Id == req.ClientId, ct)
			?? throw new NotFoundException("Cliente não encontrado.");

		client.UpdateExtraServiceDuration(req.Duration);

		await dbContext.SaveChangesAsync(ct);

		await Send.NoContentAsync(ct);
	}
}
