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
			await dbContext.Database.EnsureCreatedAsync();
		}
	}
}
