using BookingApp.Domain.Events;
using FastEndpoints;

namespace BookingApp.API.Features.Notifications.Handlers;

/// <summary>
/// Notificação de reagendamento — inclui info sobre taxa quando aplicável.
/// </summary>
public sealed class AppointmentRescheduledNotificationHandler(INotificationHub hub) : IEventHandler<AppointmentRescheduled>
{
	public async Task HandleAsync(AppointmentRescheduled e, CancellationToken ct)
	{
		var feeNote = e.FeeApplied
			? $" Uma taxa de reagendamento tardio de R$ {e.FeeAmount:F2} foi gerada."
			: string.Empty;

		var payload = new NotificationPayload(
			Type: "AppointmentRescheduled",
			Title: "Agendamento Reagendado",
			Message: e.ActorRole == "Client"
				? $"Um cliente reagendou um agendamento.{feeNote}"
				: $"Seu agendamento foi reagendado.{feeNote}",
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
