using BookingApp.Domain.Common;

namespace BookingApp.Domain.Events;

public sealed record DebtCanceled(
	Guid ClientId,
	List<Guid> DebtIds,
	decimal TotalCanceledAmount
) : DomainEvent;
