using BookingApp.API.Extentions;
using FastEndpoints;
using FastEndpoints.Swagger;

var builder = WebApplication.CreateBuilder();

var configuration = builder.Configuration;
var environment = builder.Environment;

builder.Services
	.AddEmail(configuration)
	.AddCors(options =>
	{
		options.AddDefaultPolicy(policy =>
		{
			policy.AllowAnyOrigin()
				  .AllowAnyMethod()
				  .AllowAnyHeader();
		});
	})
	.AddDbContext(configuration)
	.AddAuth(configuration, environment)
	.AddFastEndpoints()
	.AddIdempotency()
	.SwaggerDocument();

var app = builder.Build();

await app.UseDbContext();

app.UseCors()
	.UseAuthentication()
	.UseAuthorization()
	.UseOutputCache()
	.UseDefaultExceptionHandler()
	.UseFastEndpoints(config => config.Errors.UseProblemDetails())
	.UseSwaggerGen()
	.UseSwaggerUi();

await app.RunAsync();
