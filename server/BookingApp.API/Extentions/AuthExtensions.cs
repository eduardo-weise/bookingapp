namespace BookingApp.API.Extentions;

using BookingApp.Infrastructure.Authentication;
using FastEndpoints.Security;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;

public static class AuthExtensions
{
	public static IServiceCollection AddAuth(this IServiceCollection services, IConfiguration configuration)
	{
		services.Configure<JwtOptions>(configuration.GetSection("JwtOptions"));

		services
			.AddAuthenticationJwtBearer(o => o.SigningKey = configuration["JwtOptions:SecretKey"])
			.AddAuthorization()
			.AddAuthorizationBuilder()
				.AddPolicy("AdminsOnly", x => x.RequireRole("Admin").RequireClaim("UserId"))
				.AddPolicy("AdminOrManager", x => x.RequireRole("Admin", "Manager").RequireClaim("UserId"))
				.AddPolicy("All", x => x.RequireRole("Admin", "Manager", "Client").RequireClaim("UserId"));

		return services;
	}
}
