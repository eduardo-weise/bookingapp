using System.Security.Claims;
using BookingApp.Domain.Entities;
using BookingApp.Domain.Exceptions;
using BookingApp.Infrastructure.Data;
using BookingApp.Infrastructure.Settings.Authentication;
using FastEndpoints;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Auth.Register;

public sealed record RegisterRequest(string Email, string Password, string Name, string Phone, string Cpf);

public sealed class RegisterValidator : Validator<RegisterRequest>
{
	public RegisterValidator()
	{
		RuleFor(x => x.Email)
			.NotEmpty().WithMessage("O e-mail é obrigatório.")
			.EmailAddress().WithMessage("Formato de e-mail inválido.");

		RuleFor(x => x.Password)
			.NotEmpty().WithMessage("A senha é obrigatória.")
			.MinimumLength(8).WithMessage("A senha deve ter no mínimo 8 caracteres.");

		RuleFor(x => x.Name)
			.NotEmpty().WithMessage("O nome é obrigatório.");

		RuleFor(x => x.Phone)
			.NotEmpty().WithMessage("O telefone é obrigatório.");

		RuleFor(x => x.Cpf)
			.NotEmpty().WithMessage("O CPF é obrigatório.");
	}
}

public sealed class RegisterEndpoint(ApplicationDbContext dbContext)
	: Endpoint<RegisterRequest, CustomTokenResponse>
{
	public override void Configure()
	{
		Post("/auth/register");
		AllowAnonymous();
		Tags("Auth");
		Summary(s =>
		{
			s.Summary = "Register a new user.";
			s.Description = "Creates a new user and returns the user id.";
		});
	}

	public override async Task HandleAsync(RegisterRequest request, CancellationToken ct)
	{
		var existingUser = await dbContext.Users
			.AsNoTracking()
			.AnyAsync(u => u.Email == request.Email, ct);

		if (existingUser)
			throw new EmailAlreadyExistsException(request.Email);

		var passwordHash = PasswordHasher.Hash(request.Password);
		var user = new User(request.Email, passwordHash, request.Name, request.Phone, request.Cpf);

		await dbContext.Users.AddAsync(user, ct);

		var saveResult = await dbContext.SaveChangesAsync(ct);

		if (saveResult == 0)
			throw new DatabaseSaveChangesException();

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
