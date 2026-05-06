using BookingApp.Domain.Common;

namespace BookingApp.Domain.Entities;

public enum DebtStatus
{
	Pending,
	Paid,
	Canceled
}

public enum DebtType
{
	LateCancellation,
	LateReschedule,
	NoShow
}

public sealed class DebtBalance : AggregateRoot
{
	public Guid ClientId { get; private set; }
	public Guid AppointmentId { get; private set; }
	public decimal Amount { get; private set; }
	public DebtStatus Status { get; private set; }
	public DebtType Type { get; private set; }
	public string Description { get; private set; } = null!;
	public decimal FeePercentage { get; private set; }
	public DateTime CreatedAt { get; private set; }

	private DebtBalance() { } // EF Core

	public DebtBalance(Guid clientId, Guid appointmentId, decimal amount)
	{
		ClientId = clientId;
		AppointmentId = appointmentId;
		Amount = amount;
		Status = DebtStatus.Pending;
		Type = DebtType.NoShow; // Default
		Description = string.Empty;
		FeePercentage = 0;
		CreatedAt = DateTime.UtcNow;
	}

	public DebtBalance(Guid clientId, Guid appointmentId, decimal amount, DebtType type, string description, decimal feePercentage)
	{
		ClientId = clientId;
		AppointmentId = appointmentId;
		Amount = amount;
		Status = DebtStatus.Pending;
		Type = type;
		Description = description;
		FeePercentage = feePercentage;
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

	public void Cancel()
	{
		if (Status != DebtStatus.Pending)
		{
			throw new InvalidOperationException("Este débito já foi pago ou cancelado.");
		}

		Status = DebtStatus.Canceled;
	}
}
