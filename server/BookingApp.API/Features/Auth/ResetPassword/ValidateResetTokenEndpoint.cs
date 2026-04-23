using BookingApp.Infrastructure.Data;
using FastEndpoints;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Auth.ResetPassword;

public record ValidateResetTokenRequest(string Email, string Token);
public record ValidateResetTokenResponse(string Message);

public class ValidateResetTokenEndpoint : Endpoint<ValidateResetTokenRequest, ValidateResetTokenResponse>
{
	private readonly ApplicationDbContext _dbContext;

	public ValidateResetTokenEndpoint(ApplicationDbContext dbContext)
	{
		_dbContext = dbContext;
	}

	public override void Configure()
	{
		Post("/auth/validate-reset-token");
		AllowAnonymous();
	}

	public override async Task HandleAsync(ValidateResetTokenRequest req, CancellationToken ct)
	{
		var user = await _dbContext.Users.FirstOrDefaultAsync(u => u.Email == req.Email && !u.IsDeleted, ct);

		if (user == null || user.ResetPasswordToken != req.Token || user.ResetPasswordExpiry < DateTime.UtcNow)
		{
			ThrowError("O código de verificação é inválido ou expirou.");
		}

		await Send.OkAsync(new ValidateResetTokenResponse("Token válido."), cancellation: ct);
	}
}
