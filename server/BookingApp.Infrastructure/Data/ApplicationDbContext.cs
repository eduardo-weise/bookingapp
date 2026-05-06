using BookingApp.Domain.Common;
using BookingApp.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.Infrastructure.Data;

public sealed class ApplicationDbContext(
	DbContextOptions<ApplicationDbContext> options) : DbContext(options)
{
	public DbSet<User> Users => Set<User>();
	public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
	public DbSet<Service> Services => Set<Service>();
	public DbSet<Appointment> Appointments => Set<Appointment>();
	public DbSet<SwapRequest> SwapRequests => Set<SwapRequest>();
	public DbSet<AbsenceDay> AbsenceDays => Set<AbsenceDay>();
	public DbSet<DebtBalance> DebtBalances => Set<DebtBalance>();

	protected override void OnModelCreating(ModelBuilder modelBuilder)
	{
		modelBuilder.Ignore<DomainEvent>();
		modelBuilder.ApplyConfigurationsFromAssembly(typeof(ApplicationDbContext).Assembly);
		base.OnModelCreating(modelBuilder);
	}
}
