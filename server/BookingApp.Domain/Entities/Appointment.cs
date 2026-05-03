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

	public void Cancel(bool allowLateCancellation = false)
	{
		if (Status != AppointmentStatus.Scheduled)
		{
			throw new InvalidOperationException("Somente agendamentos ativos podem ser cancelados.");
		}

		// Regra das 24h
		if (!allowLateCancellation && (StartTime - DateTime.UtcNow).TotalHours < 24)
		{
			throw new InvalidOperationException("Cancelamento requer 24h de antecedência.");
		}

		Status = AppointmentStatus.Canceled;
	}

	public void MarkAsRescheduled(bool allowLateReschedule = false)
	{
		if (Status != AppointmentStatus.Scheduled)
		{
			throw new InvalidOperationException("Somente agendamentos ativos podem ser reagendados.");
		}

		if (!allowLateReschedule && (StartTime - DateTime.UtcNow).TotalHours < 1)
		{
			throw new InvalidOperationException("Reagendamento não permitido com menos de 1h de antecedência.");
		}

		Status = AppointmentStatus.Rescheduled;
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
