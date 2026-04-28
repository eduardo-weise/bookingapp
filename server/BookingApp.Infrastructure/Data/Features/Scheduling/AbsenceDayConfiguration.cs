using BookingApp.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BookingApp.Infrastructure.Data.Features.Scheduling;

internal sealed class AbsenceDayConfiguration : IEntityTypeConfiguration<AbsenceDay>
{
	public void Configure(EntityTypeBuilder<AbsenceDay> builder)
	{
		builder.HasKey(ad => ad.Id);

		builder.HasIndex(ad => new { ad.StartDate, ad.EndDate });

		builder.Property(ad => ad.StartDate)
			.HasColumnType("timestamp without time zone")
			.IsRequired();

		builder.Property(ad => ad.EndDate)
			.HasColumnType("timestamp without time zone")
			.IsRequired();
	}
}
