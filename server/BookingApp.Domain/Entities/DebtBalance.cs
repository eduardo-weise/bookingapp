using BookingApp.Domain.Common;

namespace BookingApp.Domain.Entities;

public enum DebtStatus
{
	Pending,
	Paid,
	Waived
}

public sealed class DebtBalance : AggregateRoot
{
	public Guid ClientId { get; private set; }
	public Guid AppointmentId { get; private set; }
	public decimal Amount { get; private set; }
	public DebtStatus Status { get; private set; }
	public DateTime CreatedAt { get; private set; }

	private DebtBalance() { } // EF Core

	public DebtBalance(Guid clientId, Guid appointmentId, decimal amount)
	{
		ClientId = clientId;
		AppointmentId = appointmentId;
		Amount = amount;
		Status = DebtStatus.Pending;
		CreatedAt = DateTime.UtcNow;
	}

	public void MarkAsPaid()
	{
		if (Status != DebtStatus.Pending)
		{
			throw new InvalidOperationException("Este débito já foi pago ou perdoado.");
		}

		Status = DebtStatus.Paid;
	}

	public void Waive()
	{
		if (Status != DebtStatus.Pending)
		{
			throw new InvalidOperationException("Este débito já foi pago ou perdoado.");
		}

		Status = DebtStatus.Waived;
	}
}
