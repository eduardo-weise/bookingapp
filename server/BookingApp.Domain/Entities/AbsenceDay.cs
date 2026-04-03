using BookingApp.Domain.Common;

namespace BookingApp.Domain.Entities;

public sealed class AbsenceDay : AggregateRoot
{
	public DateTime Date { get; private set; }

	private AbsenceDay() { } // EF Core

	public AbsenceDay(DateTime date)
	{
		Date = date.Date; // Garante que a hora seja zerada
	}
}
