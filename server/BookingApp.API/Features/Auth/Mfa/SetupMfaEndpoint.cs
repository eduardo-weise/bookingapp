using System.Security.Claims;
using BookingApp.Domain.Exceptions;
using BookingApp.Infrastructure.Data;
using FastEndpoints;
using Google.Authenticator;
using Microsoft.EntityFrameworkCore;
using OtpNet;
using Base32Encoding = Google.Authenticator.Base32Encoding;

namespace BookingApp.API.Features.Auth.Mfa;

public sealed record SetupMfaResponse(string SecretKey, string QrCodeUri);

public sealed class SetupMfaEndpoint(ApplicationDbContext dbContext)
	: EndpointWithoutRequest<SetupMfaResponse>
{
	public override void Configure()
	{
		Post("/auth/mfa/setup");
		Tags("Auth");
		Options(x => x.WithName("SetupMfa"));
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
			.SingleOrDefaultAsync(u => u.Id == userId, ct);

		if (user is null)
			throw new NotFoundException("User not found.");

		if (user.IsMfaEnabled)
			throw new ConflictException("MFA já está configurado para este usuário.");

		var secretBytes = KeyGeneration.GenerateRandomKey(20);
		var secret = Base32Encoding.ToString(secretBytes);

		user.EnableMfa(secret);

		var authenticator = new TwoFactorAuthenticator();
		var setupCode = authenticator.GenerateSetupCode("BookingApp", user.Email, secret, false, 3);

		await dbContext.SaveChangesAsync(ct);

		await Send.OkAsync(new SetupMfaResponse(secret, setupCode.QrCodeSetupImageUrl), cancellation: ct);
	}
}
