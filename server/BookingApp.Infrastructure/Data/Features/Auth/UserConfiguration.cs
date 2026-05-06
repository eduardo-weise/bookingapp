using BookingApp.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BookingApp.Infrastructure.Data.Features.Auth;

internal sealed class UserConfiguration : IEntityTypeConfiguration<User>
{
	public void Configure(EntityTypeBuilder<User> builder)
	{
		builder.HasKey(u => u.Id);

		builder.HasQueryFilter(u => !u.IsDeleted);

		builder.HasIndex(u => u.Email).IsUnique();

		builder.Property(u => u.Email)
			   .IsRequired()
			   .HasMaxLength(200);

		builder.Property(u => u.PasswordHash)
			   .IsRequired();

		builder.Property(u => u.ExtraServiceDuration)
			   .IsRequired();

		builder.HasMany(u => u.RefreshTokens)
			.WithOne(rt => rt.User)
			.HasForeignKey(rt => rt.UserId)
			.OnDelete(DeleteBehavior.Cascade);
	}
}
