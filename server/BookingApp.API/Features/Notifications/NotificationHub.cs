using System.Collections.Concurrent;
using System.Threading.Channels;

namespace BookingApp.API.Features.Notifications;

/// <summary>
/// Implementação singleton do hub SSE.
/// Mantém dicionário em memória de conexões ativas e roteia notificações por role/userId.
/// </summary>
public sealed class NotificationHub : INotificationHub
{
	private sealed record SseConnection(Guid UserId, string Role, Channel<NotificationPayload> Channel);

	private readonly ConcurrentDictionary<string, SseConnection> _connections = new();

	public ChannelReader<NotificationPayload> RegisterConnection(string connectionId, Guid userId, string role)
	{
		var channel = Channel.CreateBounded<NotificationPayload>(new BoundedChannelOptions(32)
		{
			FullMode = BoundedChannelFullMode.DropOldest,
			SingleReader = true,
			SingleWriter = false
		});

		_connections[connectionId] = new SseConnection(userId, role, channel);
		return channel.Reader;
	}

	public void UnregisterConnection(string connectionId)
	{
		if (_connections.TryRemove(connectionId, out var conn))
			conn.Channel.Writer.TryComplete();
	}

	public async ValueTask PublishToAdminsAsync(NotificationPayload payload)
	{
		foreach (var (_, conn) in _connections)
		{
			if (conn.Role is "Admin" or "Manager")
				await conn.Channel.Writer.WriteAsync(payload);
		}
	}

	public async ValueTask PublishToClientAsync(Guid clientId, NotificationPayload payload)
	{
		foreach (var (_, conn) in _connections)
		{
			if (conn.UserId == clientId && conn.Role == "Client")
				await conn.Channel.Writer.WriteAsync(payload);
		}
	}
}
