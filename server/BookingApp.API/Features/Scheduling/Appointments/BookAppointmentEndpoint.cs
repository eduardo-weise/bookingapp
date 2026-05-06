using System.Security.Claims;
using BookingApp.API.Extentions;
using BookingApp.Domain.Entities;
using BookingApp.Domain.Exceptions;
using BookingApp.Infrastructure.Data;
using BookingApp.Infrastructure.Settings.Authentication;
using FastEndpoints;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Scheduling.BookAppointment;

public sealed record BookAppointmentRequest(Guid ServiceId, DateTime StartTime, Guid? ClientId = null);

public sealed class BookAppointmentValidator : Validator<BookAppointmentRequest>
{
	public BookAppointmentValidator()
	{
		RuleFor(x => x.ServiceId).NotEmpty();
		RuleFor(x => x.StartTime).NotEmpty();
	}
}

public sealed class BookAppointmentEndpoint(ApplicationDbContext dbContext)
	: Endpoint<BookAppointmentRequest, object>
{
	public override void Configure()
	{
		Post("/appointments");
		Policies(UserPolicy.All);
		Tags("Application");
		Options(x => x.WithName("BookAppointment"));
	}

	public override async Task HandleAsync(BookAppointmentRequest req, CancellationToken ct)
	{
		var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
		if (!Guid.TryParse(userIdString, out var authenticatedUserId))
		{
			await Send.UnauthorizedAsync(ct);
			return;
		}

		var isAdminOrManager = User.IsInRole("Admin") || User.IsInRole("Manager");
		var targetClientId = authenticatedUserId;

		if (req.ClientId.HasValue)
		{
			if (!isAdminOrManager)
			{
				await Send.ForbiddenAsync(ct);
				return;
			}

			targetClientId = req.ClientId.Value;
		}

		var client = await dbContext.Users
			.AsNoTracking()
			.SingleOrDefaultAsync(u => u.Id == targetClientId, ct);

		if (client is null)
			throw new NotFoundException("Cliente não encontrado.");

		var service = await dbContext.Services
			.AsNoTracking()
			.SingleOrDefaultAsync(s => s.Id == req.ServiceId, ct);

		if (service is null)
			throw new NotFoundException("Serviço não encontrado.");

		var duration = service.DefaultDuration + client.ExtraServiceDuration;
		var startTime = req.StartTime.EnsureUtc();
		var endTime = startTime.Add(duration);

		var hasAbsenceConflict = await dbContext.AbsenceDays
			.AsNoTracking()
			.AnyAsync(a => a.StartDate < endTime && a.EndDate > startTime, ct);

		if (hasAbsenceConflict)
			throw new ConflictException("Não é possível agendar em um dia de ausência programada.");

		var hasOverlap = await dbContext.Appointments
			.AsNoTracking()
			.AnyAsync(a => a.Status == AppointmentStatus.Scheduled &&
						   a.StartTime < endTime && a.EndTime > startTime, ct);

		if (hasOverlap)
			throw new ConflictException("Horário não disponível.");

		var appointment = new Appointment(targetClientId, req.ServiceId, startTime, endTime);

		await dbContext.Appointments.AddAsync(appointment, ct);
		await dbContext.SaveChangesAsync(ct);

		await Send.CreatedAtAsync<BookAppointmentEndpoint>(null, new { Id = appointment.Id }, cancellation: ct);
	}
}
