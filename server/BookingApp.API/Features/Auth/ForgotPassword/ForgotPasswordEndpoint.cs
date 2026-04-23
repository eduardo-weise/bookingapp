using BookingApp.Domain.Entities;
using BookingApp.Infrastructure.Data;
using FastEndpoints;
using FluentEmail.Core;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Auth.ForgotPassword;

public record ForgotPasswordRequest(string Email);
public record ForgotPasswordResponse(string Message);

public class ForgotPasswordEndpoint : Endpoint<ForgotPasswordRequest, ForgotPasswordResponse>
{
	private readonly ApplicationDbContext _dbContext;
	private readonly IFluentEmail _fluentEmail;

	public ForgotPasswordEndpoint(ApplicationDbContext dbContext, IFluentEmail fluentEmail)
	{
		_dbContext = dbContext;
		_fluentEmail = fluentEmail;
	}

	public override void Configure()
	{
		Post("/auth/forgot-password");
		AllowAnonymous();
	}

	public override async Task HandleAsync(ForgotPasswordRequest req, CancellationToken ct)
	{
		var user = await _dbContext.Users.FirstOrDefaultAsync(u => u.Email == req.Email && !u.IsDeleted, ct);

		if (user != null)
		{
			// Generate 6-digit pin
			var random = new Random();
			var pin = random.Next(100000, 999999).ToString();
			
			user.GeneratePasswordResetToken(pin, DateTime.UtcNow.AddMinutes(15));
			await _dbContext.SaveChangesAsync(ct);

			// Send email using FluentEmail
			await _fluentEmail
				.To(user.Email, user.Name ?? "Usuário")
				.Subject("Recuperação de Senha - Agendê")
				.Body($@"
					<h1>Recuperação de Senha</h1>
					<p>Olá,</p>
					<p>Seu código de verificação para alteração de senha é: <strong>{pin}</strong></p>
					<p>Este código expira em 15 minutos.</p>
					<p>Se você não solicitou, apenas ignore este e-mail.</p>",
					isHtml: true)
				.SendAsync(ct);
		}

		// Always return success to prevent email enumeration
		await Send.OkAsync(new ForgotPasswordResponse("Se o e-mail estiver cadastrado, um link de recuperação será enviado em instantes."), cancellation: ct);
	}
}
