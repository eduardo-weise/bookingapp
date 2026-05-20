using BookingApp.Domain.Common;

namespace BookingApp.Domain.Events;

public sealed record AppointmentRescheduled(
	Guid AppointmentId,
	Guid ClientId,
	Guid ActorId,
	string ActorRole,
	bool FeeApplied,
	decimal? FeeAmount
) : DomainEvent;
