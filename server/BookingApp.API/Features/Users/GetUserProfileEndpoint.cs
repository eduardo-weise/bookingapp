using System.Security.Claims;
using BookingApp.Domain.Exceptions;
using BookingApp.Infrastructure.Data;
using BookingApp.Infrastructure.Settings.Authentication;
using FastEndpoints;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Users.GetUserProfile;

public sealed record UserProfileDto(Guid Id, string Email, string? Name, string? PhoneNumber, bool IsMfaEnabled);

public sealed class GetUserProfileEndpoint(ApplicationDbContext dbContext)
	: EndpointWithoutRequest<UserProfileDto>
{
	public override void Configure()
	{
		Get("/users");
		Policies(UserPolicy.All);
		Tags("Users");
		Options(x => x.WithName("GetUserProfile"));
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
			.AsNoTracking()
			.SingleOrDefaultAsync(u => u.Id == userId, ct)
			?? throw new NotFoundException("Usuário não encontrado.");

		await Send.OkAsync(new UserProfileDto(user.Id, user.Email, user.Name, user.PhoneNumber, user.IsMfaEnabled), cancellation: ct);
	}
}
