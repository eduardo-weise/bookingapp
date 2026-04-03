using BookingApp.API.Extentions;
using FastEndpoints;
using FastEndpoints.Swagger;

var builder = WebApplication.CreateBuilder(args);

var configuration = builder.Configuration;

// Add services to the container.
builder.Services
	.AddDbContext(configuration)
	.AddAuth(configuration)
	.AddFastEndpoints()
	.AddIdempotency()
	.SwaggerDocument();

// Runtime configuration
var app = builder.Build();

await app.UseDbContext();

app.UseAuthentication()
	.UseAuthorization()
	.UseOutputCache()
	.UseDefaultExceptionHandler()
	.UseFastEndpoints(config => config.Errors.UseProblemDetails())
	.UseSwaggerGen()
	.UseSwaggerUi();

await app.RunAsync();
