namespace BookingApp.Domain.Exceptions;

public sealed class EmailAlreadyExistsException(string email)
	: AppException(
		"EMAIL_ALREADY_EXISTS",
		$"O e-mail '{email}' já está em uso.")
{
}
