using BookingApp.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace BookingApp.API.Extentions;

public static class DbContextExtension
{
	extension(IServiceCollection services)
	{
		public IServiceCollection AddDbContext(IConfiguration configuration) =>
			services.AddDbContext<ApplicationDbContext>(options =>
				options.UseNpgsql(
					configuration.GetConnectionString("DefaultConnection")));
	}

	extension(WebApplication app)
	{
		public async Task UseDbContext()
		{
			using var scope = app.Services.CreateScope();
			var dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
			await dbContext.Database.MigrateAsync();

			// Seed Admin User
			var adminEmail = "weise.eduardo@gmail.com";
			if (!await dbContext.Users.AnyAsync(u => u.Email == adminEmail))
			{
				var passwordHash = BookingApp.Infrastructure.Settings.Authentication.PasswordHasher.Hash("P@ssw0rd");
				var adminUser = new BookingApp.Domain.Entities.User(
					email: adminEmail,
					passwordHash: passwordHash,
					name: "Eduardo Wesie",
					phoneNumber: "55981035906",
					cpf: "01861126026",
					role: "Admin"
				);

				await dbContext.Users.AddAsync(adminUser);
				await dbContext.SaveChangesAsync();
			}
		}
	}
}
