using BookingApp.Domain.Events;
using FastEndpoints;

namespace BookingApp.API.Features.Notifications.Handlers;

/// <summary>
/// Roteia notificação de agendamento criado: cliente agendou → admin; admin agendou → cliente.
/// </summary>
public sealed class AppointmentBookedNotificationHandler(INotificationHub hub) : IEventHandler<AppointmentBooked>
{
	public async Task HandleAsync(AppointmentBooked e, CancellationToken ct)
	{
		var payload = new NotificationPayload(
			Type: "AppointmentBooked",
			Title: "Novo Agendamento",
			Message: e.ActorRole == "Client"
				? "Um cliente realizou um novo agendamento."
				: "Um agendamento foi criado para você.",
			AppointmentId: e.AppointmentId,
			ClientId: e.ClientId,
			FeeApplied: false,
			FeeAmount: null,
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
