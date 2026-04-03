using BookingApp.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BookingApp.Infrastructure.Data.Features.Services;

internal sealed class ServiceConfiguration : IEntityTypeConfiguration<Service>
{
	public void Configure(EntityTypeBuilder<Service> builder)
	{
		builder.HasKey(s => s.Id);

		builder.Property(s => s.Name)
			   .IsRequired()
			   .HasMaxLength(150);

		builder.Property(s => s.Price)
			   .HasColumnType("numeric(10,2)")
			   .IsRequired();

		builder.Property(s => s.DefaultDuration)
			   .IsRequired();
	}
}
