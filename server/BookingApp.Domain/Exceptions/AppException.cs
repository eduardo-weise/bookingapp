namespace BookingApp.Domain.Exceptions;

public abstract class AppException(
	string code,
	string message,
	Exception? innerException = null)
	: Exception(message, innerException)
{
	public string Code { get; } = code;
}
