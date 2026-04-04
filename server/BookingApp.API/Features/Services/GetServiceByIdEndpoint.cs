using BookingApp.Domain.Exceptions;
using BookingApp.Infrastructure.Data;
using FastEndpoints;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Services.GetServiceById;

public sealed record ServiceDetailsDto(Guid Id, string Name, TimeSpan DefaultDuration, decimal Price);

public sealed record GetServiceByIdRequest(Guid Id);

public sealed class GetServiceByIdEndpoint(ApplicationDbContext dbContext)
	: Endpoint<GetServiceByIdRequest, ServiceDetailsDto>
{
	public override void Configure()
	{
		Get("/services/{id:guid}");
		AllowAnonymous();
		Tags("Services");
		Options(x => x.WithName("GetServiceById"));
	}

	public override async Task HandleAsync(GetServiceByIdRequest req, CancellationToken ct)
	{
		var service = await dbContext.Services
			.AsNoTracking()
			.SingleOrDefaultAsync(s => s.Id == req.Id, ct)
			?? throw new NotFoundException("Serviço não encontrado.");

		await Send.OkAsync(new ServiceDetailsDto(service.Id, service.Name, service.DefaultDuration, service.Price), cancellation: ct);
	}
}
