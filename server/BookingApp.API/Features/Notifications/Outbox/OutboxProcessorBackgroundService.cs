using System.Text.Json;
using BookingApp.API.Features.Notifications.Outbox;
using BookingApp.Domain.Entities;
using BookingApp.Infrastructure.Data;
using FastEndpoints;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace BookingApp.API.Features.Notifications.Outbox;

public sealed class OutboxProcessorBackgroundService(
	IServiceScopeFactory scopeFactory,
	IOptions<OutboxOptions> options,
	ILogger<OutboxProcessorBackgroundService> logger) : BackgroundService
{
	private readonly OutboxOptions _options = options.Value;

	protected override async Task ExecuteAsync(CancellationToken stoppingToken)
	{
		using var timer = new PeriodicTimer(TimeSpan.FromSeconds(_options.ProcessIntervalSeconds));

		while (await timer.WaitForNextTickAsync(stoppingToken))
		{
			try
			{
				await ProcessOutboxMessagesAsync(stoppingToken);
			}
			catch (Exception ex)
			{
				logger.LogError(ex, "Erro no processamento de mensagens do Outbox.");
			}
		}
	}

	private async Task ProcessOutboxMessagesAsync(CancellationToken stoppingToken)
	{
		using var scope = scopeFactory.CreateScope();
		var dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

		var messages = await dbContext.OutboxMessages
			.Where(m => m.ProcessedOn == null)
			.OrderBy(m => m.OccurredOn)
			.Take(50)
			.ToListAsync(stoppingToken);

		if (messages.Count == 0)
			return;

		foreach (var message in messages)
		{
			try
			{
				var type = Type.GetType(message.Type);
				if (type is null)
				{
					message.MarkAsFailed($"Type {message.Type} not found.");
					continue;
				}

				var domainEvent = JsonSerializer.Deserialize(message.Content, type);
				if (domainEvent is null)
				{
					message.MarkAsFailed($"Failed to deserialize {message.Type}.");
					continue;
				}

				// The 'domainEvent' is cast as 'object'. FastEndpoints 'PublishAsync' uses standard MediatR-like
				// extension method `await event.PublishAsync()`, but requires type inference.
				// However, FastEndpoints extension: `PublishAsync(this IEvent eventModel, ...)`.
				// To invoke it generically, we can resolve the generic method or just publish to EventBus.
				// Another option is FastEndpoints.EventBus<TEvent>.PublishAsync. We can use reflection.
				
				var eventType = typeof(EventBus<>).MakeGenericType(type);
				var publishMethod = eventType.GetMethod("PublishAsync", System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Static);
				
				if (publishMethod is not null)
				{
					// EventBus<TEvent>.PublishAsync(TEvent eventModel, Mode mode = Mode.WaitForNone, CancellationToken cancellation = default)
					var task = (Task)publishMethod.Invoke(null, new[] { domainEvent, FastEndpoints.Mode.WaitForAll, stoppingToken })!;
					await task;
					message.MarkAsProcessed();
				}
				else
				{
					message.MarkAsFailed("EventBus.PublishAsync method not found for this type.");
				}
			}
			catch (Exception ex)
			{
				logger.LogError(ex, "Erro ao processar mensagem {MessageId}", message.Id);
				message.MarkAsFailed(ex.Message);
			}
		}

		await dbContext.SaveChangesAsync(stoppingToken);
	}
}
