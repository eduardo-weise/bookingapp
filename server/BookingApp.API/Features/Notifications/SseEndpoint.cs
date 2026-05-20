using System.Security.Claims;
using System.Text.Json;
using BookingApp.Infrastructure.Settings.Authentication;
using FastEndpoints;

namespace BookingApp.API.Features.Notifications;

/// <summary>
/// Endpoint SSE autenticado. Mantém conexão aberta e envia notificações em tempo real.
/// GET /notifications/stream
/// </summary>
public sealed class SseEndpoint(INotificationHub hub) : EndpointWithoutRequest
{
	private static readonly JsonSerializerOptions _jsonOptions = new(JsonSerializerDefaults.Web);

	public override void Configure()
	{
		Get("/notifications/stream");
		Policies(UserPolicy.All);
		Tags("Notifications");
		Options(x => x.WithName("NotificationsStream"));
	}

	public override async Task HandleAsync(CancellationToken ct)
	{
		var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
		if (!Guid.TryParse(userIdStr, out var userId))
		{
			await Send.UnauthorizedAsync(ct);
			return;
		}

		var role = User.FindFirstValue(ClaimTypes.Role)
			?? User.Claims.FirstOrDefault(c => c.Type.EndsWith("/role", StringComparison.OrdinalIgnoreCase))?.Value
			?? "Client";

		// Configura headers SSE
		HttpContext.Response.ContentType = "text/event-stream";
		HttpContext.Response.Headers.CacheControl = "no-cache";
		HttpContext.Response.Headers.Append("X-Accel-Buffering", "no");
		HttpContext.Response.Headers.Append("Connection", "keep-alive");

		await HttpContext.Response.Body.FlushAsync(ct);

		var connectionId = Guid.NewGuid().ToString();
		var reader = hub.RegisterConnection(connectionId, userId, role);

		try
		{
			using var heartbeatTimer = new PeriodicTimer(TimeSpan.FromSeconds(30));
			var heartbeatTask = HeartbeatAsync(heartbeatTimer, ct);

			await foreach (var payload in reader.ReadAllAsync(ct))
			{
				var json = JsonSerializer.Serialize(payload, _jsonOptions);
				await WriteEventAsync($"data: {json}\n\n", ct);
			}

			await heartbeatTask;
		}
		catch (OperationCanceledException)
		{
			// Cliente desconectou — normal
		}
		finally
		{
			hub.UnregisterConnection(connectionId);
		}
	}

	private async Task HeartbeatAsync(PeriodicTimer timer, CancellationToken ct)
	{
		try
		{
			while (await timer.WaitForNextTickAsync(ct))
				await WriteEventAsync(": heartbeat\n\n", ct);
		}
		catch (OperationCanceledException) { }
	}

	private async Task WriteEventAsync(string data, CancellationToken ct)
	{
		await HttpContext.Response.WriteAsync(data, ct);
		await HttpContext.Response.Body.FlushAsync(ct);
	}
}
