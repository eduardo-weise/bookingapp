namespace BookingApp.API.Features.Notifications;

public sealed record NotificationPayload(
	string Type,
	string Title,
	string Message,
	Guid? AppointmentId,
	Guid? ClientId,
	bool FeeApplied,
	decimal? FeeAmount,
	decimal? TotalAmount,
	List<Guid>? DebtIds,
	DateTime OccurredOn
);
