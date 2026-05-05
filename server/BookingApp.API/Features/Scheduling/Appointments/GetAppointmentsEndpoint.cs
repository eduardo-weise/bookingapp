using System.Security.Claims;
using BookingApp.API.Extentions;
using BookingApp.Domain.Entities;
using BookingApp.Infrastructure.Data;
using BookingApp.Infrastructure.Settings.Authentication;
using FastEndpoints;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Scheduling.GetAppointments;

public sealed class GetAppointmentsRequest
{
	[QueryParam] public DateTime? Date { get; set; }
}

public sealed record AppointmentDto(
	Guid Id,
	string ServiceName,
	decimal ServicePrice,
	DateTime StartTime,
	DateTime EndTime,
	string Status,
	string? ClientName = null
);

public sealed class GetAppointmentsEndpoint(ApplicationDbContext dbContext)
	: Endpoint<GetAppointmentsRequest, List<AppointmentDto>>
{
	public override void Configure()
	{
		Get("/appointments");
		Policies(UserPolicy.All);
		Tags("Application");
		Options(x => x.WithName("GetAppointments"));
	}

	public override async Task HandleAsync(GetAppointmentsRequest req, CancellationToken ct)
	{
		if (User.IsInRole("Admin") || User.IsInRole("Manager"))
		{
			if (req.Date is null)
			{
				AddError(r => r.Date, "A data é obrigatória para admin/manager.");
				await Send.ErrorsAsync(cancellation: ct);
				return;
			}

			await HandleAdminAsync(req.Date.Value, ct);
			return;
		}

		await HandleClientAsync(ct);
	}

	private async Task HandleClientAsync(CancellationToken ct)
	{
		var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
		if (!Guid.TryParse(userIdString, out var clientId))
		{
			await Send.UnauthorizedAsync(ct);
			return;
		}

		var todayStart = DateTime.UtcNow.Date;

		var appointments = await dbContext.Appointments
			.AsNoTracking()
			.Where(a => a.ClientId == clientId)
			.Where(a => a.StartTime >= todayStart)
			.Where(a => a.Status == AppointmentStatus.Scheduled || a.Status == AppointmentStatus.Rescheduled)
			.OrderBy(a => a.StartTime)
			.Select(a => new { a.Id, a.ServiceId, a.StartTime, a.EndTime, a.Status })
			.ToListAsync(ct);

		if (appointments.Count == 0)
		{
			await Send.OkAsync([], ct);
			return;
		}

		var serviceIds = appointments.Select(a => a.ServiceId).Distinct().ToList();

		var servicesById = await dbContext.Services
			.AsNoTracking()
			.Where(s => serviceIds.Contains(s.Id))
			.ToDictionaryAsync(s => s.Id, s => new { s.Name, s.Price }, ct);

		var response = appointments
			.Select(a =>
			{
				servicesById.TryGetValue(a.ServiceId, out var service);

				return new AppointmentDto(
					a.Id,
					service?.Name ?? "Serviço removido",
					service?.Price ?? 0m,
					a.StartTime,
					a.EndTime,
					a.Status.ToString()
				);
			})
			.ToList();

		await Send.OkAsync(response, cancellation: ct);
	}

	private async Task HandleAdminAsync(DateTime date, CancellationToken ct)
	{
		var dayStart = date.EnsureUtcDate();
		var dayEnd = dayStart.AddDays(1);

		var appointments = await dbContext.Appointments
			.AsNoTracking()
			.Where(a => a.StartTime >= dayStart && a.StartTime < dayEnd)
			.Where(a => a.Status == AppointmentStatus.Scheduled || a.Status == AppointmentStatus.Rescheduled)
			.Select(a => new { a.Id, a.ClientId, a.ServiceId, a.StartTime, a.EndTime, a.Status })
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
			.Select(u => new { u.Id, u.Name })
			.ToListAsync(ct);

		var services = await dbContext.Services
			.AsNoTracking()
			.Where(s => serviceIds.Contains(s.Id))
			.Select(s => new { s.Id, s.Name, s.Price })
			.ToListAsync(ct);

		var usersById = users.ToDictionary(u => u.Id);
		var servicesById = services.ToDictionary(s => s.Id);

		var response = appointments
			.Select(a =>
			{
				usersById.TryGetValue(a.ClientId, out var user);
				servicesById.TryGetValue(a.ServiceId, out var service);

				return new AppointmentDto(
					a.Id,
					service?.Name ?? "Serviço removido",
					service?.Price ?? 0m,
					a.StartTime,
					a.EndTime,
					a.Status.ToString(),
					user?.Name ?? "Cliente removido"
				);
			})
			.ToList();

		await Send.OkAsync(response, cancellation: ct);
	}
}
