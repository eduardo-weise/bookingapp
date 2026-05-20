using BookingApp.Domain.Events;
using FastEndpoints;

namespace BookingApp.API.Features.Notifications.Handlers;

/// <summary>
/// Notificação de cancelamento de débito (admin cancelou taxa) → notifica o cliente dono dos débitos.
/// </summary>
public sealed class DebtCanceledNotificationHandler(INotificationHub hub) : IEventHandler<DebtCanceled>
{
	public async Task HandleAsync(DebtCanceled e, CancellationToken ct)
	{
		var payload = new NotificationPayload(
			Type: "DebtCanceled",
			Title: "Taxa Cancelada",
			Message: $"Débitos no valor total de R$ {e.TotalCanceledAmount:F2} foram cancelados.",
			AppointmentId: null,
			ClientId: e.ClientId,
			FeeApplied: false,
			FeeAmount: null,
			TotalAmount: e.TotalCanceledAmount,
			DebtIds: e.DebtIds,
			OccurredOn: e.OccurredOn
		);

		await hub.PublishToClientAsync(e.ClientId, payload);
	}
}
