using BookingApp.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BookingApp.Infrastructure.Data.Features.Scheduling;

internal sealed class SwapRequestConfiguration : IEntityTypeConfiguration<SwapRequest>
{
	public void Configure(EntityTypeBuilder<SwapRequest> builder)
	{
		builder.HasKey(sr => sr.Id);

		builder.Property(sr => sr.Status)
			   .HasConversion<string>()
			   .IsRequired();

		builder.HasOne<Appointment>()
			   .WithMany()
			   .HasForeignKey(sr => sr.RequesterAppointmentId)
			   .OnDelete(DeleteBehavior.Restrict);

		builder.HasOne<Appointment>()
			   .WithMany()
			   .HasForeignKey(sr => sr.TargetAppointmentId)
			   .OnDelete(DeleteBehavior.Restrict);
	}
}
