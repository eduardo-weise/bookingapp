using BookingApp.Domain.Events;
using FastEndpoints;

namespace BookingApp.API.Features.Notifications.Handlers;

/// <summary>
/// Notificação de no-show → sempre destinada ao cliente. Taxa de 50% sempre presente.
/// </summary>
public sealed class AppointmentNoShowedNotificationHandler(INotificationHub hub) : IEventHandler<AppointmentNoShowed>
{
	public async Task HandleAsync(AppointmentNoShowed e, CancellationToken ct)
	{
		var payload = new NotificationPayload(
			Type: "AppointmentNoShowed",
			Title: "Não Comparecimento",
			Message: $"Você foi marcado como não comparecimento. Uma multa de R$ {e.FeeAmount:F2} foi aplicada.",
			AppointmentId: e.AppointmentId,
			ClientId: e.ClientId,
			FeeApplied: true,
			FeeAmount: e.FeeAmount,
			TotalAmount: null,
			DebtIds: null,
			OccurredOn: e.OccurredOn
		);

		await hub.PublishToClientAsync(e.ClientId, payload);
	}
}
