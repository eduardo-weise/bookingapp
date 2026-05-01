using BookingApp.API.Extentions;
using BookingApp.Domain.Entities;
using BookingApp.Infrastructure.Data;
using FastEndpoints;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Scheduling.GetAppointmentsByDate;

public sealed class GetAppointmentsByDateRequest
{
	[QueryParam] public DateTime Date { get; set; }
}

public sealed record AppointmentByDateDto(
	Guid Id,
	string ClientName,
	string ServiceName,
	DateTime StartTime,
	string Status
);

public sealed class GetAppointmentsByDateEndpoint(ApplicationDbContext dbContext)
	: Endpoint<GetAppointmentsByDateRequest, List<AppointmentByDateDto>>
{
	public override void Configure()
	{
		Get("/appointments/by-date");
		Policies("AdminOrManager");
		Tags("Application");
		Options(x => x.WithName("GetAppointmentsByDate"));
	}

	public override async Task HandleAsync(GetAppointmentsByDateRequest req, CancellationToken ct)
	{
		var dayStart = req.Date.EnsureUtcDate();
		var dayEnd = dayStart.AddDays(1);

		var appointments = await dbContext.Appointments
			.AsNoTracking()
			.Where(a => a.StartTime >= dayStart && a.StartTime < dayEnd)
			.Where(a => a.Status == AppointmentStatus.Scheduled || a.Status == AppointmentStatus.Rescheduled)
			.Select(a => new { a.Id, a.ClientId, a.ServiceId, a.StartTime, a.Status })
			.OrderBy(a => a.StartTime)
			.ToListAsync(ct);

		if (appointments.Count == 0)
		{
			await Send.NoContentAsync(ct);
			return;
		}

		var clientIds = appointments.Select(a => a.ClientId).Distinct().ToList();
		var serviceIds = appointments.Select(a => a.ServiceId).Distinct().ToList();

		var users = await dbContext.Users
			.AsNoTracking()
			.Where(u => clientIds.Contains(u.Id))
			.Select(u => new { u.Id, u.Name, u.Email })
			.ToListAsync(ct);

		var services = await dbContext.Services
			.AsNoTracking()
			.Where(s => serviceIds.Contains(s.Id))
			.Select(s => new { s.Id, s.Name })
			.ToListAsync(ct);

		var usersById = users.ToDictionary(u => u.Id);
		var servicesById = services.ToDictionary(s => s.Id);

		var response = appointments
			.Select(a =>
			{
				usersById.TryGetValue(a.ClientId, out var user);
				servicesById.TryGetValue(a.ServiceId, out var service);

				var clientName = user?.Name ?? "Cliente removido";
				var serviceName = service?.Name ?? "Serviço removido";

				return new AppointmentByDateDto(
					a.Id,
					clientName,
					serviceName,
					a.StartTime,
					a.Status.ToString()
				);
			})
			.ToList();

		await Send.OkAsync(response, cancellation: ct);
	}
}