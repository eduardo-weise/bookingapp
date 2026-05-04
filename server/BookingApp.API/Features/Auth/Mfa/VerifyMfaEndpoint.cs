using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using BookingApp.Domain.Exceptions;
using BookingApp.Infrastructure.Data;
using BookingApp.Infrastructure.Settings.Authentication;
using FastEndpoints;
using FluentValidation;
using Google.Authenticator;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Auth.Mfa;

public sealed record VerifyMfaRequest(string TempToken, string Code);

public sealed class VerifyMfaValidator : Validator<VerifyMfaRequest>
{
	public VerifyMfaValidator()
	{
		RuleFor(x => x.TempToken)
			.NotEmpty();
		RuleFor(x => x.Code)
			.NotEmpty()
			.Length(6);
	}
}

public sealed class VerifyMfaEndpoint(ApplicationDbContext dbContext)
	: Endpoint<VerifyMfaRequest, CustomTokenResponse>
{
	public override void Configure()
	{
		Post("/auth/mfa/verify");
		AllowAnonymous();
		Tags("Auth");
		Options(x => x.WithName("VerifyMfa"));
	}

	public override async Task HandleAsync(VerifyMfaRequest request, CancellationToken ct)
	{
		var handler = new JwtSecurityTokenHandler();
		var jwt = handler.ReadJwtToken(request.TempToken);
		var userId = Guid.Parse(jwt.Claims.First(c => c.Type == JwtRegisteredClaimNames.Sub).Value);

		var user = await dbContext.Users
			.SingleOrDefaultAsync(u => u.Id == userId, ct);

		if (user is null)
			throw new UnauthorizedAccessException("Usuário inválido.");

		if (!user.IsMfaEnabled || string.IsNullOrEmpty(user.MfaSecret))
			throw new ConflictException("MFA não está habilitado para este usuário.");

		var authenticator = new TwoFactorAuthenticator();
		var isValid = authenticator.ValidateTwoFactorPIN(user.MfaSecret, request.Code);

		if (!isValid)
			throw new UnauthorizedAccessException("Código MFA inválido.");

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
