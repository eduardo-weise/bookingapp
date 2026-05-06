namespace BookingApp.API.Extentions;

internal static class DateTimeExtention
{
	public static DateTime EnsureUtc(this DateTime value)
	{
		return value.Kind switch
		{
			DateTimeKind.Utc => value,
			DateTimeKind.Local => value.ToUniversalTime(),
			DateTimeKind.Unspecified => value.ToUniversalTime(),  // Converte Unspecified como se fosse local
			_ => value.ToUniversalTime()
		};
	}

	public static DateTime EnsureUtcDate(this DateTime value)
	{
		return value.EnsureUtc().Date;
	}
}