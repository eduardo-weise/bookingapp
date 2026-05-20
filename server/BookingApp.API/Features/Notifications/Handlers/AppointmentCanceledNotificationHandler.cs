using BookingApp.Domain.Events;
using FastEndpoints;

namespace BookingApp.API.Features.Notifications.Handlers;

/// <summary>
/// Notificação de cancelamento — inclui info sobre taxa quando aplicável.
/// </summary>
public sealed class AppointmentCanceledNotificationHandler(INotificationHub hub) : IEventHandler<AppointmentCanceled>
{
	public async Task HandleAsync(AppointmentCanceled e, CancellationToken ct)
	{
		var feeNote = e.FeeApplied
			? $" Uma taxa de cancelamento tardio de R$ {e.FeeAmount:F2} foi gerada."
			: string.Empty;

		var payload = new NotificationPayload(
			Type: "AppointmentCanceled",
			Title: "Agendamento Cancelado",
			Message: e.ActorRole == "Client"
				? $"Um cliente cancelou um agendamento.{feeNote}"
				: $"Seu agendamento foi cancelado.{feeNote}",
			AppointmentId: e.AppointmentId,
			ClientId: e.ClientId,
			FeeApplied: e.FeeApplied,
			FeeAmount: e.FeeAmount,
			TotalAmount: null,
			DebtIds: null,
			OccurredOn: e.OccurredOn
		);

		if (e.ActorRole == "Client")
			await hub.PublishToAdminsAsync(payload);
		else
			await hub.PublishToClientAsync(e.ClientId, payload);
	}
}
