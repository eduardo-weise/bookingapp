namespace BookingApp.Domain.Exceptions;

public sealed class DatabaseSaveChangesException(Exception? innerException = null)
	: AppException(
		"DATABASE_SAVE_FAILED",
		"Falha ao persistir alterações no banco de dados.",
		innerException)
{
}
