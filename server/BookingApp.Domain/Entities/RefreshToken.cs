using BookingApp.Domain.Common;

namespace BookingApp.Domain.Entities;

public sealed class RefreshToken : Entity
{
	public Guid UserId { get; private set; }
	public User User { get; private set; } = null!;
	public string TokenHash { get; private set; }
	public DateTime ExpiresAt { get; private set; }
	public DateTime CreatedAt { get; private set; }
	public DateTime? RevokedAt { get; private set; }

	public bool IsExpired => DateTime.UtcNow >= ExpiresAt;
	public bool IsRevoked => RevokedAt != null;
	public bool IsActive => !IsRevoked && !IsExpired;

	private RefreshToken() { TokenHash = null!; } // EF Core

	public RefreshToken(Guid userId, string tokenHash, DateTime expiresAt)
	{
		UserId = userId;
		TokenHash = tokenHash;
		ExpiresAt = expiresAt;
		CreatedAt = DateTime.UtcNow;
	}

	public void Revoke()
	{
		RevokedAt = DateTime.UtcNow;
	}
}
