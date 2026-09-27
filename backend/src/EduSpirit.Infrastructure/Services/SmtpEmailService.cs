using System.Net;
using System.Net.Mail;
using EduSpirit.Application.Interfaces;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace EduSpirit.Infrastructure.Services;

/// <summary>
/// تنفيذ بسيط عبر SMTP القياسي — يعمل مع أي مزوّد (SendGrid, Mailgun, Amazon SES...) عبر
/// إعدادات appsettings فقط بدون تعديل كود. الفشل في الإرسال لا يوقف تدفق التسجيل الأساسي
/// (نسجّل الخطأ فقط) حتى لا يمنع مشكلة بريدية مستخدمًا من إنشاء حسابه.
/// </summary>
public class SmtpEmailService : IEmailService
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<SmtpEmailService> _logger;

    public SmtpEmailService(IConfiguration configuration, ILogger<SmtpEmailService> logger)
    {
        _configuration = configuration;
        _logger = logger;
    }

    public Task SendEmailVerificationAsync(string toEmail, string userName, string verificationLink) =>
        SendAsync(toEmail, "تأكيد بريدك الإلكتروني - EduSpirit",
            $"<p>مرحبًا {userName}،</p><p>يرجى تأكيد بريدك الإلكتروني بالضغط على الرابط التالي:</p>" +
            $"<p><a href=\"{verificationLink}\">تأكيد البريد الإلكتروني</a></p>" +
            "<p>هذا الرابط صالح لمدة 24 ساعة.</p>");

    public Task SendPasswordResetAsync(string toEmail, string userName, string resetLink) =>
        SendAsync(toEmail, "إعادة تعيين كلمة المرور - EduSpirit",
            $"<p>مرحبًا {userName}،</p><p>اضغط على الرابط التالي لإعادة تعيين كلمة المرور:</p>" +
            $"<p><a href=\"{resetLink}\">إعادة تعيين كلمة المرور</a></p>" +
            "<p>هذا الرابط صالح لمدة ساعة واحدة فقط. إن لم تطلب هذا، تجاهل الرسالة.</p>");

    private async Task SendAsync(string toEmail, string subject, string htmlBody)
    {
        var section = _configuration.GetSection("Email");
        var host = section["SmtpHost"];
        var port = int.Parse(section["SmtpPort"] ?? "587");
        var senderEmail = section["SenderEmail"] ?? "no-reply@eduspirit.app";
        var senderName = section["SenderName"] ?? "EduSpirit";
        var username = section["Username"];
        var password = section["Password"];

        try
        {
            using var client = new SmtpClient(host, port)
            {
                EnableSsl = true,
                Credentials = new NetworkCredential(username, password),
            };

            using var message = new MailMessage
            {
                From = new MailAddress(senderEmail, senderName),
                Subject = subject,
                Body = htmlBody,
                IsBodyHtml = true,
            };
            message.To.Add(toEmail);

            await client.SendMailAsync(message);
        }
        catch (Exception ex)
        {
            // لا نُفشل عملية التسجيل/الاستعادة كاملة بسبب مشكلة بريدية عابرة — نسجّلها فقط للمتابعة.
            _logger.LogError(ex, "فشل إرسال البريد الإلكتروني إلى {Email}", toEmail);
        }
    }
}
