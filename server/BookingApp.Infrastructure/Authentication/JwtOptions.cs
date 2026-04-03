namespace BookingApp.Infrastructure.Authentication;

public sealed class JwtOptions
{
	public string Issuer { get; set; } = string.Empty;
	public string Audience { get; set; } = string.Empty;
	public string SecretKey { get; set; } = string.Empty;
	public TimeSpan AccessTokenExpirationMinutes { get; set; } = TimeSpan.FromMinutes(15);
	public TimeSpan RefreshTokenExpirationDays { get; set; } = TimeSpan.FromDays(7);
}
