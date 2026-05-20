namespace BookingApp.API.Features.Notifications.Outbox;

public sealed class OutboxOptions
{
	public int ProcessIntervalSeconds { get; set; } = 10;
}
