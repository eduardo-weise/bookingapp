using System.Security.Claims;
using BookingApp.Domain.Entities;
using BookingApp.Infrastructure.Data;
using FastEndpoints;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Scheduling.GetAppointmentHistory;

public sealed record AppointmentDto(Guid Id, Guid ServiceId, DateTime StartTime, DateTime EndTime, AppointmentStatus Status);

public sealed class GetAppointmentHistoryEndpoint(ApplicationDbContext dbContext)
	: EndpointWithoutRequest<List<AppointmentDto>>
{
	public override void Configure()
	{
		Get("/appointments/history");
		Tags("Scheduling");
		Options(x => x.WithName("GetAppointmentHistory"));
	}

	public override async Task HandleAsync(CancellationToken ct)
	{
		var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
		if (!Guid.TryParse(userIdString, out var clientId))
		{
			await Send.UnauthorizedAsync(ct);
			return;
		}

		var appointments = await dbContext.Appointments
			.AsNoTracking()
			.Where(a => a.ClientId == clientId)
			.OrderByDescending(a => a.StartTime)
			.Select(a => new AppointmentDto(a.Id, a.ServiceId, a.StartTime, a.EndTime, a.Status))
			.ToListAsync(ct);

		await Send.OkAsync(appointments, cancellation: ct);
	}
}
