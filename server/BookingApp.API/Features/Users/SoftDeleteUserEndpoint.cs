using System.Security.Claims;
using BookingApp.Domain.Exceptions;
using BookingApp.Infrastructure.Data;
using BookingApp.Infrastructure.Settings.Authentication;
using FastEndpoints;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Users.SoftDeleteUser;

public sealed class SoftDeleteUserEndpoint(ApplicationDbContext dbContext)
	: EndpointWithoutRequest
{
	public override void Configure()
	{
		Delete("/users");
		Policies(UserPolicy.AdminOrManager);
		Tags("Users");
		Options(x => x.WithName("SoftDeleteUser"));
	}

	public override async Task HandleAsync(CancellationToken ct)
	{
		var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
		if (!Guid.TryParse(userIdString, out var userId))
		{
			await Send.UnauthorizedAsync(ct);
			return;
		}

		var user = await dbContext.Users
			.SingleOrDefaultAsync(u => u.Id == userId, ct)
			?? throw new NotFoundException("Usuário não encontrado.");

		user.SoftDelete();
		user.RevokeAllRefreshTokens();

		await dbContext.SaveChangesAsync(ct);

		await Send.NoContentAsync(ct);
	}
}
