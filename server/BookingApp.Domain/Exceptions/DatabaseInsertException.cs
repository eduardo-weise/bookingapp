namespace BookingApp.Domain.Exceptions;

public sealed class DatabaseInsertException(
	string entityName,
	Exception? innerException = null)

	: AppException(
		"DATABASE_INSERT_FAILED",
		$"Falha ao adicionar a entidade '{entityName}' no banco de dados.",
		innerException)
{
}
