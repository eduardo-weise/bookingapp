using BookingApp.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BookingApp.Infrastructure.Data.Features.Scheduling;

internal sealed class AbsenceDayConfiguration : IEntityTypeConfiguration<AbsenceDay>
{
	public void Configure(EntityTypeBuilder<AbsenceDay> builder)
	{
		builder.HasKey(ad => ad.Id);

		builder.HasIndex(ad => ad.Date)
			   .IsUnique();

		builder.Property(ad => ad.Date)
			   .HasColumnType("date") // Ensures it tracks only the day
			   .IsRequired();
	}
}
