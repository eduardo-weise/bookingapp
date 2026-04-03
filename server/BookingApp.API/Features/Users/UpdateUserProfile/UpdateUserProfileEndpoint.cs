using System.Security.Claims;
using BookingApp.Domain.Exceptions;
using BookingApp.Infrastructure.Data;
using FastEndpoints;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Users.UpdateUserProfile;

public sealed record UpdateUserProfileRequest(string Name, string PhoneNumber);

public sealed class UpdateUserProfileValidator : Validator<UpdateUserProfileRequest>
{
	public UpdateUserProfileValidator()
	{
		RuleFor(x => x.Name).NotEmpty().MaximumLength(150);
		RuleFor(x => x.PhoneNumber).NotEmpty().MaximumLength(20);
	}
}

public sealed class UpdateUserProfileEndpoint(ApplicationDbContext dbContext)
	: Endpoint<UpdateUserProfileRequest>
{
	public override void Configure()
	{
		Put("/users/me");
		Tags("Users");
		Options(x => x.WithName("UpdateUserProfile"));
	}

	public override async Task HandleAsync(UpdateUserProfileRequest req, CancellationToken ct)
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

		user.UpdateProfile(req.Name, req.PhoneNumber);

		await dbContext.SaveChangesAsync(ct);

		await Send.NoContentAsync(ct);
	}
}
