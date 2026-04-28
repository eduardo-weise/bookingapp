using BookingApp.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BookingApp.Infrastructure.Data.Features.Scheduling;

internal sealed class AppointmentConfiguration : IEntityTypeConfiguration<Appointment>
{
	public void Configure(EntityTypeBuilder<Appointment> builder)
	{
		builder.HasKey(a => a.Id);

		builder.HasIndex(a => new { a.ClientId, a.StartTime });

		builder.Property(a => a.StartTime)
			   .HasColumnType("timestamp with time zone")
			   .IsRequired();

		builder.Property(a => a.EndTime)
			   .HasColumnType("timestamp with time zone")
			   .IsRequired();

		builder.Property(a => a.Status)
			   .HasConversion<string>()
			   .IsRequired();

		builder.HasOne<User>()
			   .WithMany()
			   .HasForeignKey(a => a.ClientId)
			   .OnDelete(DeleteBehavior.Restrict);

		builder.HasOne<Service>()
			   .WithMany()
			   .HasForeignKey(a => a.ServiceId)
			   .OnDelete(DeleteBehavior.Restrict);
	}
}
