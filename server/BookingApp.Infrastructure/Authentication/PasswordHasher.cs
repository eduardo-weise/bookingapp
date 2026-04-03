using BCrypt.Net;

namespace BookingApp.Infrastructure.Authentication;

public static class PasswordHasher
{
	public static string Hash(string password)
	{
		return BCrypt.Net.BCrypt.EnhancedHashPassword(password, hashType: HashType.SHA384);
	}

	public static bool Verify(string password, string passwordHash)
	{
		return BCrypt.Net.BCrypt.EnhancedVerify(password, passwordHash, hashType: HashType.SHA384);
	}
}
