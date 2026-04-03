using BookingApp.Domain.Common;

namespace BookingApp.Domain.Events;

public sealed record AppointmentNoShowed(Guid AppointmentId, Guid ClientId) : DomainEvent;
