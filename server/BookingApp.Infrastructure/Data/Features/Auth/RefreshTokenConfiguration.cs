using BookingApp.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BookingApp.Infrastructure.Data.Features.Auth;

internal sealed class RefreshTokenConfiguration : IEntityTypeConfiguration<RefreshToken>
{
	public void Configure(EntityTypeBuilder<RefreshToken> builder)
	{
		builder.HasKey(rt => rt.Id);

		builder.HasIndex(rt => rt.TokenHash).IsUnique();

		builder.Property(rt => rt.TokenHash)
			   .IsRequired();

		builder.Property(rt => rt.ExpiresAt)
			   .HasColumnType("timestamp with time zone")
			   .HasConversion(
				   c => c.Kind == DateTimeKind.Utc ? c : c.ToUniversalTime(),  // save: garante UTC
				   c => DateTime.SpecifyKind(c, DateTimeKind.Utc))            // read: sempre UTC
			   .IsRequired();

		builder.Property(rt => rt.CreatedAt)
			   .HasColumnType("timestamp with time zone")
			   .HasConversion(
				   c => c.Kind == DateTimeKind.Utc ? c : c.ToUniversalTime(),  // save: garante UTC
				   c => DateTime.SpecifyKind(c, DateTimeKind.Utc))            // read: sempre UTC
			   .IsRequired();

		builder.Property(rt => rt.RevokedAt)
			   .HasColumnType("timestamp with time zone");
	}
}
