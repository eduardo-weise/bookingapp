using BookingApp.Domain.Common;

namespace BookingApp.Domain.Entities;

public enum SwapRequestStatus
{
	Pending,
	Accepted,
	Declined,
	Expired
}

public sealed class SwapRequest : AggregateRoot
{
	public Guid RequesterAppointmentId { get; private set; }
	public Guid TargetAppointmentId { get; private set; }
	public DateTime CreatedAt { get; private set; }
	public DateTime ExpiresAt { get; private set; }
	public SwapRequestStatus Status { get; private set; }

	private SwapRequest() { } // EF Core

	public SwapRequest(Guid requesterId, Guid targetId, TimeSpan ttl)
	{
		RequesterAppointmentId = requesterId;
		TargetAppointmentId = targetId;
		CreatedAt = DateTime.UtcNow;
		ExpiresAt = DateTime.UtcNow.Add(ttl);
		Status = SwapRequestStatus.Pending;
	}

	public void Accept()
	{
		if (Status != SwapRequestStatus.Pending)
		{
			throw new InvalidOperationException("Esta solicitação não está mais pendente.");
		}

		if (DateTime.UtcNow > ExpiresAt)
		{
			throw new InvalidOperationException("Esta solicitação expirou.");
		}

		Status = SwapRequestStatus.Accepted;
	}

	public void Decline()
	{
		if (Status == SwapRequestStatus.Pending)
		{
			Status = SwapRequestStatus.Declined;
		}
	}

	public void CheckExpiration()
	{
		if (Status == SwapRequestStatus.Pending && DateTime.UtcNow > ExpiresAt)
		{
			Status = SwapRequestStatus.Expired;
		}
	}
}
