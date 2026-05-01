namespace BookingApp.API.Features.Scheduling.Appointments;

internal static class SchedulingWindows
{
	private static readonly TimeSpan[] _windowBoundaries =
	[
		new(8, 0, 0),
		new(11, 0, 0),
		new(14, 0, 0),
		new(21, 0, 0)
	];

	public static IEnumerable<TimeSpan> EnumerateSlotStarts(double durationMinutes)
	{
		for (var index = 0; index < _windowBoundaries.Length; index += 2)
		{
			var windowStart = _windowBoundaries[index];
			var windowEnd = _windowBoundaries[index + 1];
			var currentSlot = windowStart;

			while (currentSlot.Add(TimeSpan.FromMinutes(durationMinutes)) <= windowEnd)
			{
				yield return currentSlot;
				currentSlot = currentSlot.Add(TimeSpan.FromMinutes(30));
			}
		}
	}
}
