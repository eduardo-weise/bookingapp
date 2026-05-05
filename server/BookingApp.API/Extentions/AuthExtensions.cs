using System.Security.Claims;
using System.Text;
using BookingApp.Infrastructure.Settings.Authentication;
using FastEndpoints.Security;
using Microsoft.IdentityModel.Tokens;

namespace BookingApp.API.Extentions;

public static class AuthExtensions
{
	extension(IServiceCollection services)
	{
		public IServiceCollection AddAuth(IConfiguration configuration, IWebHostEnvironment environment)
		{
			services.Configure<JwtOptions>(configuration.GetSection("JwtOptions"));

			var secretKey = configuration["JwtOptions:SecretKey"]!;
			var signingKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey));

			services
			.AddAuthenticationJwtBearer(
				signingOptions =>
				{
					signingOptions.SigningKey = secretKey;
				},
				bearerOptions =>
				{
					bearerOptions.TokenValidationParameters = new TokenValidationParameters
					{
						ValidateIssuer = true,
						ValidateAudience = true,
						ValidateLifetime = true,
						ValidateIssuerSigningKey = true,
						ValidIssuer = configuration["JwtOptions:Issuer"],
						ValidAudience = configuration["JwtOptions:Audience"],
						IssuerSigningKey = signingKey,
						ClockSkew = TimeSpan.Zero,
						RoleClaimType = ClaimTypes.Role,
						NameClaimType = ClaimTypes.NameIdentifier,
						ValidAlgorithms = [SecurityAlgorithms.HmacSha256],
						ValidTypes = ["JWT"],
						AuthenticationType = "Bearer"
					};

					if (!environment.IsProduction())
					{
						bearerOptions.Events = new Microsoft.AspNetCore.Authentication.JwtBearer.JwtBearerEvents
						{
							OnTokenValidated = context =>
							{
								var claims = context.Principal?.Claims.ToList() ?? [];
								System.Diagnostics.Debug.WriteLine($"=== JWT VALIDADO ===");
								System.Diagnostics.Debug.WriteLine($"Total de claims: {claims.Count}");
								claims.ForEach(c => System.Diagnostics.Debug.WriteLine($"  • {c.Type} = {c.Value}"));

								// Especificamente procure por claims de role
								var roleClaims = claims.Where(c => c.Type.Contains("role", StringComparison.OrdinalIgnoreCase)).ToList();
								System.Diagnostics.Debug.WriteLine($"Claims de role encontrados: {roleClaims.Count}");
								roleClaims.ForEach(c => System.Diagnostics.Debug.WriteLine($"  ⚠️  {c.Type} = {c.Value}"));

								return Task.CompletedTask;
							},
							OnAuthenticationFailed = context =>
							{
								System.Diagnostics.Debug.WriteLine($"❌ Auth Failed: {context.Exception?.Message}");
								return Task.CompletedTask;
							},
							OnForbidden = context =>
							{
								System.Diagnostics.Debug.WriteLine($"❌ Forbidden - Autorização rejeitada");
								return Task.CompletedTask;
							}
						};
					}

				})
			.AddAuthorizationBuilder()
				.AddPolicy(UserPolicy.AdminOnly, x => x.RequireRole("Admin"))
				.AddPolicy(UserPolicy.AdminOrManager, x => x.RequireRole("Admin", "Manager"))
				.AddPolicy(UserPolicy.All, x => x.RequireAuthenticatedUser());

			return services;
		}
	}
}
