namespace BookingApp.Domain.Exceptions;

public sealed class NotFoundException(string message)
	: AppException("NOT_FOUND", message)
{
}
