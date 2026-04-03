using BookingApp.Domain.Common;

namespace BookingApp.Domain.Entities;

public sealed class ClientServiceDuration : AggregateRoot
{
	public Guid ClientId { get; private set; }
	public Guid ServiceId { get; private set; }
	public TimeSpan Duration { get; private set; }

	private ClientServiceDuration() { } // EF Core

	public ClientServiceDuration(Guid clientId, Guid serviceId, TimeSpan duration)
	{
		ClientId = clientId;
		ServiceId = serviceId;
		Duration = duration;
	}

	public void UpdateDuration(TimeSpan newDuration)
	{
		Duration = newDuration;
	}
}
