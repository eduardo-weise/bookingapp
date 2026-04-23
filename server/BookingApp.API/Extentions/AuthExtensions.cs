using System.Security.Claims;
using BookingApp.Infrastructure.Settings.Authentication;
using FastEndpoints.Security;

namespace BookingApp.API.Extentions;

public static class AuthExtensions
{
	public static IServiceCollection AddAuth(this IServiceCollection services, IConfiguration configuration)
	{
		services.Configure<JwtOptions>(configuration.GetSection("JwtOptions"));

		services
			.AddAuthenticationJwtBearer(o => o.SigningKey = configuration["JwtOptions:SecretKey"])
			.AddAuthorization()
			.AddAuthorizationBuilder()
				.AddPolicy("AdminsOnly", x => x.RequireRole("Admin").RequireClaim(ClaimTypes.NameIdentifier))
				.AddPolicy("AdminOrManager", x => x.RequireRole("Admin", "Manager").RequireClaim(ClaimTypes.NameIdentifier))
				.AddPolicy("All", x => x.RequireRole("Admin", "Manager", "Client").RequireClaim(ClaimTypes.NameIdentifier));

		return services;
	}
}
