namespace BookingApp.Domain.Exceptions;

public sealed class ConflictException(string message)
	: AppException("CONFLICT", message)
{
}
