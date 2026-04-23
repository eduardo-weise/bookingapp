using System.Security.Claims;
using BookingApp.Domain.Entities;
using BookingApp.Infrastructure.Data;
using FastEndpoints;
using FastEndpoints.Security;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;

namespace BookingApp.Infrastructure.Settings.Authentication;

public class TokenService : RefreshTokenService<TokenRequest, CustomTokenResponse>
{
	private const string _credentialsError = "Credenciais inválidas.";
	private readonly IServiceScopeFactory _scopeFactory;

	public TokenService(IServiceScopeFactory scopeFactory, IOptions<JwtOptions> authConfig)
	{
		_scopeFactory = scopeFactory;

		Setup(o =>
		{
			o.TokenSigningKey = authConfig.Value.SecretKey;
			o.Issuer = authConfig.Value.Issuer;
			o.Audience = authConfig.Value.Audience;
			o.AccessTokenValidity = authConfig.Value.AccessTokenExpirationMinutes;
			o.RefreshTokenValidity = authConfig.Value.RefreshTokenExpirationDays;

			o.Endpoint("/auth/refresh", ep =>
			{
				ep.AllowAnonymous();
				ep.Tags("Auth");
			});
		});
	}

	private async Task ExecuteWithDbContextAsync(Func<ApplicationDbContext, Task> action)
	{
		using var scope = _scopeFactory.CreateScope();
		var dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
		await action(dbContext);
	}

	// chamado sempre que um novo par access/refresh é gerado — persiste no banco
	public override async Task PersistTokenAsync(CustomTokenResponse response)
	{
		if (!Guid.TryParse(response.UserId, out var userId))
		{
			AddError(_credentialsError);
			return;
		}

		await ExecuteWithDbContextAsync(async dbContext =>
		{
			var user = await dbContext.Users
				.SingleOrDefaultAsync(u => u.Id == userId);

			if (user is null)
			{
				AddError(_credentialsError);
				return;
			}

			user.AddRefreshToken(new RefreshToken(
				user.Id,
				response.RefreshToken,
				response.RefreshExpiry));

			await dbContext.SaveChangesAsync();
		});
	}

	public override async Task RefreshRequestValidationAsync(TokenRequest request)
	{
		if (!Guid.TryParse(request.UserId, out var userId))
		{
			AddError(_credentialsError);
			return;
		}

		await ExecuteWithDbContextAsync(async dbContext =>
		{
			var user = await dbContext.Users
				.Include(u => u.RefreshTokens)
				.SingleOrDefaultAsync(u => u.Id == userId);

			if (user is null)
			{
				AddError(_credentialsError);
				return;
			}

			var hasValidToken = user.HasValidRefreshToken(request.RefreshToken);
			if (!hasValidToken)
				AddError(r => r.RefreshToken, "Refresh token inválido ou expirado.");
		});
	}

	public override async Task SetRenewalPrivilegesAsync(TokenRequest request, UserPrivileges privileges)
	{
		if (Guid.TryParse(request.UserId, out var userId))
		{
			await ExecuteWithDbContextAsync(async dbContext =>
			{
				var userRole = await dbContext.Users
					.Where(u => u.Id == userId)
					.Select(u => u.Role)
					.SingleOrDefaultAsync();

				if (!string.IsNullOrEmpty(userRole))
				{
					privileges.Roles.Add(userRole);
				}
			});
		}

		privileges.Claims.Add(new(ClaimTypes.NameIdentifier, request.UserId));
	}
}
