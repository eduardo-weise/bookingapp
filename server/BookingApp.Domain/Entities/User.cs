using BookingApp.Domain.Common;

namespace BookingApp.Domain.Entities;

public sealed class User : AggregateRoot
{
	public string Email { get; private set; }
	public string PasswordHash { get; private set; }
	public string? Name { get; private set; }
	public string? PhoneNumber { get; private set; }
	public string? Cpf { get; private set; }
	public bool IsMfaEnabled { get; private set; }
	public string? MfaSecret { get; private set; }
	public bool IsDeleted { get; private set; }
	public string Role { get; private set; }

	// Password Recovery
	public string? ResetPasswordToken { get; private set; }
	public DateTime? ResetPasswordExpiry { get; private set; }

	// Navigation property
	private readonly List<RefreshToken> _refreshTokens = new();
	public IReadOnlyList<RefreshToken> RefreshTokens => _refreshTokens;

	private User() { Email = null!; PasswordHash = null!; Role = null!; } // EF Core

	public User(string email, string passwordHash, string? name, string? phoneNumber, string? cpf, string role = "Client")
	{
		Email = email;
		PasswordHash = passwordHash;
		Name = name;
		PhoneNumber = phoneNumber;
		Cpf = cpf;
		Role = role;
		IsMfaEnabled = false;
		IsDeleted = false;
	}

	public void UpdateProfile(string name, string phoneNumber, string? cpf = null)
	{
		Name = name;
		PhoneNumber = phoneNumber;
		if (cpf != null) Cpf = cpf;
	}

	public void GeneratePasswordResetToken(string token, DateTime expiry)
	{
		ResetPasswordToken = token;
		ResetPasswordExpiry = expiry;
	}

	public void UpdatePassword(string newPasswordHash)
	{
		PasswordHash = newPasswordHash;
		ResetPasswordToken = null;
		ResetPasswordExpiry = null;
	}

	public void AssignRole(string role)
	{
		Role = role;
	}

	public void SoftDelete()
	{
		IsDeleted = true;
	}

	public void EnableMfa(string secret)
	{
		IsMfaEnabled = true;
		MfaSecret = secret;
	}

	public void AddRefreshToken(RefreshToken refreshToken)
	{
		_refreshTokens.Add(refreshToken);
	}

	public void RevokeAllRefreshTokens()
	{
		foreach (var token in _refreshTokens.Where(rt => rt.IsActive))
		{
			token.Revoke();
		}
	}

	public bool HasValidRefreshToken(string refreshToken)
	{
		// O FastEndpoints armazena o hash do token, então compare o hash
		return _refreshTokens.Any(rt => rt.TokenHash == refreshToken && rt.IsActive);
	}
}
