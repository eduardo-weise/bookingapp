using BookingApp.Infrastructure.Data;
using FastEndpoints;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Services.GetServices;

public sealed record ServiceDto(Guid Id, string Name, TimeSpan DefaultDuration, decimal Price);

public sealed class GetServicesEndpoint(ApplicationDbContext dbContext)
	: EndpointWithoutRequest<List<ServiceDto>>
{
	public override void Configure()
	{
		Get("/services");
		AllowAnonymous();
		Tags("Services");
		Options(x => x.WithName("GetServices"));
	}

	public override async Task HandleAsync(CancellationToken ct)
	{
		var services = await dbContext.Services
			.AsNoTracking()
			.Select(s => new ServiceDto(s.Id, s.Name, s.DefaultDuration, s.Price))
			.ToListAsync(ct);

		await Send.OkAsync(services, cancellation: ct);
	}
}
