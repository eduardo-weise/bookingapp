using BookingApp.Domain.Common;

namespace BookingApp.Domain.Entities;

public sealed class AbsenceDay : AggregateRoot
{
	public DateTime StartDate { get; private set; }
	public DateTime EndDate { get; private set; }

	private AbsenceDay() { } // EF Core

	public AbsenceDay(DateTime startDate, DateTime endDate)
	{
		if (endDate < startDate)
			throw new InvalidOperationException("A data final deve ser igual ou posterior a data inicial.");

		StartDate = startDate;
		EndDate = endDate;
	}
}
