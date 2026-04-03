using FastEndpoints;

namespace BookingApp.Domain.Common;

public abstract record DomainEvent(Guid Id, DateTime OccurredOn) : IEvent
{
	protected DomainEvent() : this(Guid.NewGuid(), DateTime.UtcNow) { }
}
