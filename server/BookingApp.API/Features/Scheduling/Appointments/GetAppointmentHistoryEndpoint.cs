using System.Security.Claims;
using BookingApp.Domain.Entities;
using BookingApp.Infrastructure.Data;
using FastEndpoints;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Scheduling.GetAppointmentHistory;

public sealed record AppointmentDto(Guid Id, string ServiceName, DateTime StartTime, DateTime EndTime, string Status);

public sealed class GetAppointmentHistoryEndpoint(ApplicationDbContext dbContext)
	: EndpointWithoutRequest<List<AppointmentDto>>
{
	public override void Configure()
	{
		Get("/appointments/history");
		Policies("All");
		Tags("Application");
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
			.Select(a => new { a.Id, a.ServiceId, a.StartTime, a.EndTime, a.Status })
			.ToListAsync(ct);

		var serviceIds = appointments.Select(a => a.ServiceId).Distinct().ToList();

		var servicesById = await dbContext.Services
			.AsNoTracking()
			.Where(s => serviceIds.Contains(s.Id))
			.ToDictionaryAsync(s => s.Id, s => s.Name, ct);

		var response = appointments
			.Select(a => new AppointmentDto(
				a.Id,
				servicesById.GetValueOrDefault(a.ServiceId, "Serviço removido"),
				a.StartTime,
				a.EndTime,
				a.Status.ToString()
			))
			.ToList();

		await Send.OkAsync(response, cancellation: ct);
	}
}
