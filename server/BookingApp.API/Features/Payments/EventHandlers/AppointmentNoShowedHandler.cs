using BookingApp.Domain.Entities;
using BookingApp.Domain.Events;
using BookingApp.Infrastructure.Data;
using FastEndpoints;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Features.Payments.EventHandlers;

public sealed class AppointmentNoShowedHandler(IServiceScopeFactory scopeFactory) : IEventHandler<AppointmentNoShowed>
{
	public async Task HandleAsync(AppointmentNoShowed eventModel, CancellationToken ct)
	{
		using var scope = scopeFactory.CreateScope();
		var dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

		var appointment = await dbContext.Appointments
			.SingleOrDefaultAsync(a => a.Id == eventModel.AppointmentId, ct);

		if (appointment is null)
			return;

		var service = await dbContext.Services
			.SingleOrDefaultAsync(s => s.Id == appointment.ServiceId, ct);

		if (service is null)
			return;

		// Implementação da multa: 50% do valor do serviço
		var penaltyAmount = service.Price * 0.5m;
		var description = $"Multa por ausência (no-show) em agendamento com {service.Name}";

		var debt = new DebtBalance(eventModel.ClientId, eventModel.AppointmentId, penaltyAmount, DebtType.NoShow, description, 50);

		await dbContext.DebtBalances.AddAsync(debt, ct);

		await dbContext.SaveChangesAsync(ct);
	}
}
