using BookingApp.Domain.Exceptions;
using BookingApp.Infrastructure.Data;
using BookingApp.Infrastructure.Settings.Authentication;
using FastEndpoints;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Users.UpdateClientExtraDuration;

public sealed record UpdateClientExtraDurationRequest(Guid ClientId, int ExtraDurationMinutes);

public sealed class UpdateClientExtraDurationValidator : Validator<UpdateClientExtraDurationRequest>
{
	public UpdateClientExtraDurationValidator()
	{
		RuleFor(x => x.ClientId).NotEmpty().WithMessage("ID do cliente é obrigatório.");
		RuleFor(x => x.ExtraDurationMinutes)
			.GreaterThanOrEqualTo(0).WithMessage("A duração extra não pode ser negativa.")
			.LessThanOrEqualTo(120).WithMessage("A duração extra não pode exceder 120 minutos.");
	}
}

public sealed class UpdateClientExtraDurationEndpoint(ApplicationDbContext dbContext)
	: Endpoint<UpdateClientExtraDurationRequest>
{
	public override void Configure()
	{
		Patch("/users/clients/{ClientId}/extra-duration");
		Policies(UserPolicy.AdminOrManager);
		Tags("Users");
		Options(x => x.WithName("UpdateClientExtraDuration"));
	}

	public override async Task HandleAsync(UpdateClientExtraDurationRequest req, CancellationToken ct)
	{
		var client = await dbContext.Users
			.SingleOrDefaultAsync(u => u.Id == req.ClientId && u.Role == "Client" && !u.IsDeleted, ct)
			?? throw new NotFoundException("Cliente não encontrado.");

		client.UpdateExtraServiceDuration(TimeSpan.FromMinutes(req.ExtraDurationMinutes));

		await dbContext.SaveChangesAsync(ct);

		await Send.NoContentAsync(cancellation: ct);
	}
}
