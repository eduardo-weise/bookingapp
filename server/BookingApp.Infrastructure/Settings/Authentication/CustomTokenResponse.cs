using System.Globalization;
using FastEndpoints.Security;

namespace BookingApp.Infrastructure.Settings.Authentication;

public sealed class CustomTokenResponse : TokenResponse
{
    public string AccessTokenExpiry => AccessExpiry.ToLocalTime().ToString(CultureInfo.InvariantCulture);

	public int RefreshTokenValidityMinutes => (int)RefreshExpiry.Subtract(DateTime.UtcNow).TotalMinutes;
}
