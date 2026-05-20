using BookingApp.Domain.Common;

namespace BookingApp.Domain.Events;

public sealed record AppointmentBooked(
	Guid AppointmentId,
	Guid ClientId,
	Guid ActorId,
	string ActorRole
) : DomainEvent;
