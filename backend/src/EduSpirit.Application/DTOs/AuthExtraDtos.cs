using System.ComponentModel.DataAnnotations;

namespace EduSpirit.Application.DTOs;

public record ForgotPasswordRequest([Required, EmailAddress] string Email);
public record ResetPasswordRequest([Required] string Token, [property: Required, MinLength(8)] string NewPassword);
public record VerifyEmailRequest([Required] string Token);
public record ResendVerificationRequest([Required, EmailAddress] string Email);

/// <summary>يُرسَل من التطبيق بعد نجاح تسجيل الدخول عبر Google SDK محليًا على الجهاز — الخادم
/// يتحقق من صحة الـ ID Token مباشرة مع خوادم Google قبل إنشاء/تسجيل دخول أي حساب.</summary>
public record GoogleLoginRequest([Required] string IdToken);
