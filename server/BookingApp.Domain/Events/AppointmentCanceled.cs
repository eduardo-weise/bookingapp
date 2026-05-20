using BookingApp.Domain.Common;

namespace BookingApp.Domain.Events;

public sealed record AppointmentCanceled(
	Guid AppointmentId,
	Guid ClientId,
	Guid ActorId,
	string ActorRole,
	bool FeeApplied,
	decimal? FeeAmount
) : DomainEvent;
