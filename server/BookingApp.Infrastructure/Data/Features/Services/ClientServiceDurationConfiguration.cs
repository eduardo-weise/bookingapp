using BookingApp.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BookingApp.Infrastructure.Data.Features.Services;

internal sealed class ClientServiceDurationConfiguration : IEntityTypeConfiguration<ClientServiceDuration>
{
	public void Configure(EntityTypeBuilder<ClientServiceDuration> builder)
	{
		builder.HasKey(csd => csd.Id);

		builder.HasIndex(csd => new { csd.ClientId, csd.ServiceId }).IsUnique();

		builder.Property(csd => csd.Duration)
			   .IsRequired();

		builder.HasOne<User>()
			   .WithMany()
			   .HasForeignKey(csd => csd.ClientId)
			   .OnDelete(DeleteBehavior.Cascade);

		builder.HasOne<Service>()
			   .WithMany()
			   .HasForeignKey(csd => csd.ServiceId)
			   .OnDelete(DeleteBehavior.Cascade);
	}
}
