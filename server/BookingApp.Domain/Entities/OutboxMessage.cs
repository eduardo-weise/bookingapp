using System.Text.Json;
using BookingApp.Domain.Common;

namespace BookingApp.Domain.Entities;

public sealed class OutboxMessage : Entity
{
	public string Type { get; private set; } = string.Empty;
	public string Content { get; private set; } = string.Empty;
	public DateTime OccurredOn { get; private set; }
	public DateTime? ProcessedOn { get; private set; }
	public string? Error { get; private set; }

	// Required by EF Core
	private OutboxMessage() { }

	private OutboxMessage(string type, string content, DateTime occurredOn)
	{
		Id = Guid.NewGuid();
		Type = type;
		Content = content;
		OccurredOn = occurredOn;
	}

	public static OutboxMessage FromDomainEvent(DomainEvent domainEvent)
	{
		var type = domainEvent.GetType().AssemblyQualifiedName ?? domainEvent.GetType().Name;
		var content = JsonSerializer.Serialize(domainEvent, domainEvent.GetType());
		return new OutboxMessage(type, content, domainEvent.OccurredOn);
	}

	public void MarkAsProcessed()
	{
		ProcessedOn = DateTime.UtcNow;
	}

	public void MarkAsFailed(string error)
	{
		Error = error;
	}
}
