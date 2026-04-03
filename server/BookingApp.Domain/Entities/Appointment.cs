using BookingApp.Domain.Common;
using BookingApp.Domain.Events;

namespace BookingApp.Domain.Entities;

public enum AppointmentStatus
{
	Scheduled,
	Canceled,
	Rescheduled,
	NoShow,
	Completed
}

public sealed class Appointment : AggregateRoot
{
	public Guid ClientId { get; private set; }
	public Guid ServiceId { get; private set; }
	public DateTime StartTime { get; private set; }
	public DateTime EndTime { get; private set; }
	public AppointmentStatus Status { get; private set; }

	// For EF Core lazy loading or tracking if needed
	private Appointment() { }

	public Appointment(Guid clientId, Guid serviceId, DateTime startTime, DateTime endTime)
	{
		ClientId = clientId;
		ServiceId = serviceId;
		StartTime = startTime;
		EndTime = endTime;
		Status = AppointmentStatus.Scheduled;
	}

	public void Cancel()
	{
		if (Status != AppointmentStatus.Scheduled)
		{
			throw new InvalidOperationException("Somente agendamentos ativos podem ser cancelados.");
		}

		// Regra das 24h
		if ((StartTime - DateTime.UtcNow).TotalHours < 24)
		{
			throw new InvalidOperationException("Cancelamento requer 24h de antecedência.");
		}

		Status = AppointmentStatus.Canceled;
	}

	public void MarkAsNoShow()
	{
		if (Status == AppointmentStatus.Scheduled && DateTime.UtcNow > StartTime)
		{
			Status = AppointmentStatus.NoShow;
			AddDomainEvent(new AppointmentNoShowed(Id, ClientId));
		}
	}

	public void ChangeClient(Guid newClientId)
	{
		ClientId = newClientId;
	}
}
