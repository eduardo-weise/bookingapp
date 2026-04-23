using BookingApp.Domain.Entities;
using BookingApp.Infrastructure.Data;
using BookingApp.Infrastructure.Settings.Authentication;
using FastEndpoints;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Auth.ResetPassword;

public record ResetPasswordRequest(string Email, string Token, string NewPassword);
public record ResetPasswordResponse(string Message);

public class ResetPasswordEndpoint : Endpoint<ResetPasswordRequest, ResetPasswordResponse>
{
	private readonly ApplicationDbContext _dbContext;

	public ResetPasswordEndpoint(ApplicationDbContext dbContext)
	{
		_dbContext = dbContext;
	}

	public override void Configure()
	{
		Post("/auth/reset-password");
		AllowAnonymous();
	}

	public override async Task HandleAsync(ResetPasswordRequest req, CancellationToken ct)
	{
		var user = await _dbContext.Users.FirstOrDefaultAsync(u => u.Email == req.Email && !u.IsDeleted, ct);

		if (user == null || user.ResetPasswordToken != req.Token || user.ResetPasswordExpiry < DateTime.UtcNow)
		{
			ThrowError("O código de verificação é inválido ou expirou.");
		}

		if (req.NewPassword.Length < 8)
		{
			ThrowError("A nova senha deve ter no mínimo 8 caracteres.");
		}

		var newPasswordHash = PasswordHasher.Hash(req.NewPassword);
		user.UpdatePassword(newPasswordHash);
		
		await _dbContext.SaveChangesAsync(ct);

		await Send.OkAsync(new ResetPasswordResponse("Senha redefinida com sucesso."), cancellation: ct);
	}
}
