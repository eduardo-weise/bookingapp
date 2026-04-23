using BookingApp.Infrastructure.Settings.Email;

namespace BookingApp.API.Extentions;

public static class AddEmailExtention
{
	extension(IServiceCollection services)
	{
		public IServiceCollection AddEmail(IConfiguration configuration)
		{
			var emailSettings = configuration.GetSection("Email").Get<EmailSettings>();

			if (emailSettings != null)
			{
				services
					.AddFluentEmail(emailSettings.SenderEmail, emailSettings.SenderName)
					.AddSmtpSender(emailSettings.SmtpServer, emailSettings.SmtpPort);
			}

			return services;
		}
	}
}
