using BookingApp.Infrastructure.Data;
using BookingApp.Infrastructure.Settings.Authentication;
using FastEndpoints;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Users.GetClients;

public sealed record ClientListItemDto(Guid Id, string DisplayName, string Email);

public sealed class GetClientsEndpoint(ApplicationDbContext dbContext)
	: EndpointWithoutRequest<List<ClientListItemDto>>
{
	public override void Configure()
	{
		Get("/users/clients");
		Policies(UserPolicy.AdminOrManager);
		Tags("Users");
		Options(x => x.WithName("GetClients"));
	}

	public override async Task HandleAsync(CancellationToken ct)
	{
		var clients = await dbContext.Users
			.AsNoTracking()
			.Where(u => u.Role == "Client" && !u.IsDeleted)
			.OrderBy(u => u.Name ?? u.Email)
			.Select(u => new ClientListItemDto(
				u.Id,
				string.IsNullOrWhiteSpace(u.Name) ? u.Email : u.Name!,
				u.Email
			))
			.ToListAsync(ct);

		await Send.OkAsync(clients, cancellation: ct);
	}
}
