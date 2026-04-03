using BookingApp.Domain.Common;

namespace BookingApp.Domain.Entities;

public sealed class Service : AggregateRoot
{
	public string Name { get; private set; }
	public TimeSpan DefaultDuration { get; private set; }
	public decimal Price { get; private set; }

	private Service() { Name = null!; } // EF Core

	public Service(string name, TimeSpan defaultDuration, decimal price)
	{
		Name = name;
		DefaultDuration = defaultDuration;
		Price = price;
	}

	public void Update(string name, TimeSpan defaultDuration, decimal price)
	{
		Name = name;
		DefaultDuration = defaultDuration;
		Price = price;
	}
}
