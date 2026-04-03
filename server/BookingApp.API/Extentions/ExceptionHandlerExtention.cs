using BookingApp.Domain.Exceptions;
using Microsoft.AspNetCore.Diagnostics;

namespace BookingApp.API.Extentions;

public static class ExceptionHandlerExtention
{
	extension(IApplicationBuilder app)
	{
		public IApplicationBuilder UseDefaultExceptionHandler()
		{
			return app.UseExceptionHandler(exceptionHandler =>
			{
				exceptionHandler.Run(async context =>
				{
					var exceptionFeature = context.Features.Get<IExceptionHandlerFeature>();
					var exception = exceptionFeature?.Error;

					var (statusCode, message) = exception switch
					{
						UnauthorizedAccessException ex => (StatusCodes.Status401Unauthorized, ex.Message),
						EmailAlreadyExistsException ex => (StatusCodes.Status403Forbidden, ex.Message),
						NotFoundException ex => (StatusCodes.Status404NotFound, ex.Message),
						ConflictException ex => (StatusCodes.Status409Conflict, ex.Message),
						_ => (StatusCodes.Status500InternalServerError, "An unexpected error occurred.")
					};

					context.Response.StatusCode = statusCode;
					await context.Response.WriteAsJsonAsync(new { error = message });
				});
			});
		}
	}
}
