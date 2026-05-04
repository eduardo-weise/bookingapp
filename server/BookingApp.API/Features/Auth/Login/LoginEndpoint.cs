using System.Security.Claims;
using BookingApp.Infrastructure.Data;
using BookingApp.Infrastructure.Settings.Authentication;
using FastEndpoints;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Auth.Login;

public sealed record LoginRequest(string Email, string Password);

public sealed class LoginValidator : Validator<LoginRequest>
{
	public LoginValidator()
	{
		RuleFor(x => x.Email)
			.NotEmpty()
			.EmailAddress();

		RuleFor(x => x.Password)
			.NotEmpty();
	}
}

public sealed class LoginEndpoint(ApplicationDbContext dbContext)
	: Endpoint<LoginRequest, CustomTokenResponse>
{
	public override void Configure()
	{
		Post("/auth/login");
		AllowAnonymous();
		Tags("Auth");
	}

	public override async Task HandleAsync(LoginRequest req, CancellationToken ct)
	{
		var user = await dbContext.Users
			.SingleOrDefaultAsync(u => u.Email == req.Email, ct);

		if (user is null || !PasswordHasher.Verify(req.Password, user.PasswordHash))
		{
			await Send.UnauthorizedAsync(ct);
			return;
		}

		var token = await CreateTokenWith<TokenService>(
			user.Id.ToString(),
			privileges =>
			{
				privileges.Claims.Add(new(ClaimTypes.NameIdentifier, user.Id.ToString()));
				privileges.Claims.Add(new(ClaimTypes.Role, user.Role));
			});

		await Send.OkAsync(token, cancellation: ct);
	}
}
