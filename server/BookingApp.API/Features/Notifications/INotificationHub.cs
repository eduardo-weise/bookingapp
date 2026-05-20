namespace BookingApp.API.Features.Notifications;

/// <summary>
/// Hub SSE — gerencia conexões ativas e roteia notificações por role/userId.
/// </summary>
public interface INotificationHub
{
	/// <summary>
	/// Registra conexão SSE. Retorna reader do canal para o endpoint consumir.
	/// </summary>
	System.Threading.Channels.ChannelReader<NotificationPayload> RegisterConnection(
		string connectionId,
		Guid userId,
		string role);

	/// <summary>
	/// Remove conexão e completa o canal (encerra o stream no cliente).
	/// </summary>
	void UnregisterConnection(string connectionId);

	/// <summary>
	/// Entrega payload a todas as conexões com role Admin ou Manager (cenários 1–4).
	/// </summary>
	ValueTask PublishToAdminsAsync(NotificationPayload payload);

	/// <summary>
	/// Entrega payload à conexão do clientId específico (cenários 5–10).
	/// </summary>
	ValueTask PublishToClientAsync(Guid clientId, NotificationPayload payload);
}
