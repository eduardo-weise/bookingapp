using BookingApp.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BookingApp.Infrastructure.Data.Features.Payments;

internal sealed class DebtBalanceConfiguration : IEntityTypeConfiguration<DebtBalance>
{
	public void Configure(EntityTypeBuilder<DebtBalance> builder)
	{
		builder.HasKey(d => d.Id);

		builder.Property(d => d.Amount)
			   .HasColumnType("numeric(10,2)")
			   .IsRequired();

		builder.Property(d => d.Status)
			   .HasConversion<string>()
			   .IsRequired();

		builder.Property(d => d.Type)
			   .HasConversion<string>()
			   .IsRequired();

		builder.Property(d => d.Description)
			   .HasMaxLength(500)
			   .IsRequired();

		builder.Property(d => d.FeePercentage)
			   .HasColumnType("numeric(5,2)")
			   .IsRequired();

		builder.Property(d => d.CreatedAt)
			   .HasColumnType("timestamp with time zone")
			   .HasConversion(
				   c => c.Kind == DateTimeKind.Utc ? c : c.ToUniversalTime(),  // save: garante UTC
				   c => DateTime.SpecifyKind(c, DateTimeKind.Utc))            // read: sempre UTC
			   .IsRequired();

		builder.HasOne<User>()
			   .WithMany()
			   .HasForeignKey(d => d.ClientId)
			   .OnDelete(DeleteBehavior.Restrict);

		builder.HasOne<Appointment>()
			   .WithMany()
			   .HasForeignKey(d => d.AppointmentId)
			   .OnDelete(DeleteBehavior.Restrict);
	}
}
