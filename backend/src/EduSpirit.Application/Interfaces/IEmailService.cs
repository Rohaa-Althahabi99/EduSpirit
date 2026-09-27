namespace EduSpirit.Application.Interfaces;

public interface IEmailService
{
    Task SendEmailVerificationAsync(string toEmail, string userName, string verificationLink);
    Task SendPasswordResetAsync(string toEmail, string userName, string resetLink);
}
