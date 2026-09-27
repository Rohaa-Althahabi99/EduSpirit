using EduSpirit.Domain.Entities;

namespace EduSpirit.Application.Interfaces;

public interface IPasswordHasher
{
    string Hash(string plainPassword);
    bool Verify(string plainPassword, string hash);
}

public record TokenPair(string AccessToken, string RefreshTokenPlain, DateTime AccessTokenExpiresAt);

public interface IJwtTokenService
{
    /// <summary>يولّد Access Token (قصير العمر) و Refresh Token (يُعاد نصًا صريحًا مرة واحدة فقط للعميل).</summary>
    TokenPair GenerateTokens(User user);

    /// <summary>هاش يُستخدم لتخزين الـ Refresh Token في القاعدة (لا يُخزَّن أبدًا كنص صريح).</summary>
    string HashToken(string tokenPlain);

    Guid? ValidateAccessTokenAndGetUserId(string accessToken);
}

/// <summary>يقرأ هوية المستخدم الحالي من الـ JWT Claims — تُستخدم لضمان أن كل عملية
/// تخص صاحب الطلب فقط (Ownership Check) ولا يمكن لمستخدم الوصول لبيانات غيره.</summary>
public interface ICurrentUserService
{
    Guid UserId { get; }
    bool IsAuthenticated { get; }
}

/// <summary>يتحقق من صحة ID Token الصادر من Google مباشرة مع خوادمهم، ويستخرج البريد والاسم منه.</summary>
public record GoogleUserInfo(string Email, string FullName, string? AvatarUrl);

public interface IGoogleTokenValidator
{
    Task<GoogleUserInfo?> ValidateAsync(string idToken);
}
