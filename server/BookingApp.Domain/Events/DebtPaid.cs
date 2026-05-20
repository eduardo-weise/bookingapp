using BookingApp.Domain.Common;

namespace BookingApp.Domain.Events;

public sealed record DebtPaid(
	Guid ClientId,
	Guid PayerId,
	string PayerRole,
	List<Guid> DebtIds,
	decimal TotalAmount
) : DomainEvent;
