namespace BookingApp.API.Extentions;

internal static class DateTimeExtention
{
	public static DateTime EnsureUtc(this DateTime value)
	{
		return value.Kind switch
		{
			DateTimeKind.Utc => value,
			DateTimeKind.Local => value.ToUniversalTime(),
			DateTimeKind.Unspecified => DateTime.SpecifyKind(value, DateTimeKind.Utc),
			_ => DateTime.SpecifyKind(value, DateTimeKind.Utc)
		};
	}

	public static DateTime EnsureUtcDate(this DateTime value)
	{
		return value.EnsureUtc().Date;
	}
}