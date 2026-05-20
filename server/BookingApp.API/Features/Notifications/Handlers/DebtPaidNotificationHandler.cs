using BookingApp.Domain.Events;
using FastEndpoints;

namespace BookingApp.API.Features.Notifications.Handlers;

/// <summary>
/// Notificação de pagamento de débito.
/// PayerRole == "Client" → notifica admins (cenário 4: pagamento online).
/// PayerRole == "Admin"/"Manager" → notifica cliente (cenário 10: pagamento presencial em espécie).
/// </summary>
public sealed class DebtPaidNotificationHandler(INotificationHub hub) : IEventHandler<DebtPaid>
{
	public async Task HandleAsync(DebtPaid e, CancellationToken ct)
	{
		if (e.PayerRole == "Client")
		{
			var payload = new NotificationPayload(
				Type: "DebtPaid",
				Title: "Pagamento Recebido",
				Message: $"Um cliente pagou R$ {e.TotalAmount:F2} em débitos pendentes.",
				AppointmentId: null,
				ClientId: e.ClientId,
				FeeApplied: false,
				FeeAmount: null,
				TotalAmount: e.TotalAmount,
				DebtIds: e.DebtIds,
				OccurredOn: e.OccurredOn
			);

			await hub.PublishToAdminsAsync(payload);
		}
		else
		{
			var payload = new NotificationPayload(
				Type: "ServicePaidInPerson",
				Title: "Pagamento Registrado",
				Message: $"Um pagamento presencial de R$ {e.TotalAmount:F2} foi registrado para você.",
				AppointmentId: null,
				ClientId: e.ClientId,
				FeeApplied: false,
				FeeAmount: null,
				TotalAmount: e.TotalAmount,
				DebtIds: e.DebtIds,
				OccurredOn: e.OccurredOn
			);

			await hub.PublishToClientAsync(e.ClientId, payload);
		}
	}
}
