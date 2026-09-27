using System.Security.Cryptography;
using EduSpirit.Application.DTOs;
using EduSpirit.Application.Exceptions;
using EduSpirit.Application.Interfaces;
using EduSpirit.Domain.Entities;
using EduSpirit.Domain.Enums;

namespace EduSpirit.Application.Services;

public class AuthService
{
    private readonly IUnitOfWork _uow;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IJwtTokenService _jwtService;
    private readonly IEmailService _emailService;
    private readonly IGoogleTokenValidator _googleValidator;

    // في تطبيق حقيقي يُقرأ هذا من appsettings (رابط الواجهة الأمامية / Deep Link التطبيق).
    private const string AppDeepLinkBase = "eduspirit://auth";

    public AuthService(
        IUnitOfWork uow,
        IPasswordHasher passwordHasher,
        IJwtTokenService jwtService,
        IEmailService emailService,
        IGoogleTokenValidator googleValidator)
    {
        _uow = uow;
        _passwordHasher = passwordHasher;
        _jwtService = jwtService;
        _emailService = emailService;
        _googleValidator = googleValidator;
    }

    public async Task<AuthResponse> RegisterAsync(RegisterRequest request)
    {
        var existing = await _uow.Users.FirstOrDefaultAsync(u => u.Email == request.Email.ToLower());
        if (existing != null)
            throw new ConflictException("يوجد حساب مسجّل بهذا البريد الإلكتروني بالفعل.");

        var user = new User
        {
            FullName = request.FullName.Trim(),
            Email = request.Email.Trim().ToLower(),
            PasswordHash = _passwordHasher.Hash(request.Password),
        };

        await _uow.Users.AddAsync(user);
        await _uow.SaveChangesAsync();

        await SendVerificationEmailAsync(user);

        return await IssueTokensAsync(user);
    }

    public async Task<AuthResponse> LoginAsync(LoginRequest request)
    {
        var user = await _uow.Users.FirstOrDefaultAsync(u => u.Email == request.Email.Trim().ToLower());

        // ملاحظة أمنية: نفس رسالة الخطأ سواء كان البريد غير موجود أو كلمة المرور خاطئة
        // لمنع مهاجم من معرفة أي الحسابات مسجّلة فعلًا (User Enumeration).
        if (user == null || user.PasswordHash == string.Empty || !_passwordHasher.Verify(request.Password, user.PasswordHash))
            throw new UnauthorizedAppException("البريد الإلكتروني أو كلمة المرور غير صحيحة.");

        return await IssueTokensAsync(user);
    }

    public async Task<AuthResponse> GoogleLoginAsync(GoogleLoginRequest request)
    {
        var googleUser = await _googleValidator.ValidateAsync(request.IdToken)
                          ?? throw new UnauthorizedAppException("تعذّر التحقق من حساب Google.");

        var user = await _uow.Users.FirstOrDefaultAsync(u => u.Email == googleUser.Email.ToLower());

        if (user == null)
        {
            // حساب جديد عبر Google: لا كلمة مرور محلية له (PasswordHash فارغ يمنع تسجيل الدخول العادي به).
            user = new User
            {
                FullName = googleUser.FullName,
                Email = googleUser.Email.ToLower(),
                PasswordHash = string.Empty,
                AvatarUrl = googleUser.AvatarUrl,
                AuthProvider = AuthProvider.Google,
                IsEmailVerified = true, // Google أصلًا يضمن ملكية البريد
            };
            await _uow.Users.AddAsync(user);
            await _uow.SaveChangesAsync();
        }

        return await IssueTokensAsync(user);
    }

    public async Task<AuthResponse> RefreshAsync(string refreshTokenPlain)
    {
        var tokenHash = _jwtService.HashToken(refreshTokenPlain);
        var stored = await _uow.RefreshTokens.FirstOrDefaultAsync(t => t.TokenHash == tokenHash);

        if (stored == null || !stored.IsActive)
            throw new UnauthorizedAppException("جلسة الدخول منتهية، يرجى تسجيل الدخول من جديد.");

        var user = await _uow.Users.GetByIdAsync(stored.UserId)
                   ?? throw new UnauthorizedAppException();

        // إبطال التوكن القديم فورًا (Rotation) لمنع إعادة استخدامه لو تم تسريبه.
        stored.RevokedAt = DateTime.UtcNow;
        _uow.RefreshTokens.Update(stored);

        return await IssueTokensAsync(user);
    }

    public async Task LogoutAsync(string refreshTokenPlain)
    {
        var tokenHash = _jwtService.HashToken(refreshTokenPlain);
        var stored = await _uow.RefreshTokens.FirstOrDefaultAsync(t => t.TokenHash == tokenHash);
        if (stored != null)
        {
            stored.RevokedAt = DateTime.UtcNow;
            _uow.RefreshTokens.Update(stored);
            await _uow.SaveChangesAsync();
        }
    }

    // ------------------------- تحقق البريد الإلكتروني -------------------------

    public async Task ResendVerificationAsync(ResendVerificationRequest request)
    {
        var user = await _uow.Users.FirstOrDefaultAsync(u => u.Email == request.Email.Trim().ToLower());
        // لا نكشف للمُستدعي إن كان البريد مسجّلًا أم لا (User Enumeration) — نُرجع بصمت دائمًا.
        if (user == null || user.IsEmailVerified) return;

        await SendVerificationEmailAsync(user);
    }

    public async Task VerifyEmailAsync(VerifyEmailRequest request)
    {
        var tokenHash = _jwtService.HashToken(request.Token);
        var stored = await _uow.EmailVerificationTokens.FirstOrDefaultAsync(t => t.TokenHash == tokenHash);

        if (stored == null || !stored.IsValid)
            throw new AppException("رابط التحقق غير صالح أو منتهي الصلاحية.");

        var user = await _uow.Users.GetByIdAsync(stored.UserId) ?? throw new NotFoundException("المستخدم");
        user.IsEmailVerified = true;
        _uow.Users.Update(user);

        stored.UsedAt = DateTime.UtcNow;
        _uow.EmailVerificationTokens.Update(stored);

        await _uow.SaveChangesAsync();
    }

    private async Task SendVerificationEmailAsync(User user)
    {
        var tokenPlain = GenerateSecureToken();
        await _uow.EmailVerificationTokens.AddAsync(new EmailVerificationToken
        {
            UserId = user.Id,
            TokenHash = _jwtService.HashToken(tokenPlain),
            ExpiresAt = DateTime.UtcNow.AddHours(24),
        });
        await _uow.SaveChangesAsync();

        var link = $"{AppDeepLinkBase}/verify-email?token={Uri.EscapeDataString(tokenPlain)}";
        await _emailService.SendEmailVerificationAsync(user.Email, user.FullName, link);
    }

    // ------------------------- استعادة كلمة المرور -------------------------

    public async Task ForgotPasswordAsync(ForgotPasswordRequest request)
    {
        var user = await _uow.Users.FirstOrDefaultAsync(u => u.Email == request.Email.Trim().ToLower());
        // نفس مبدأ عدم كشف وجود الحساب: نرجع بنجاح صامت دائمًا بغض النظر عن النتيجة الفعلية.
        if (user == null) return;

        var tokenPlain = GenerateSecureToken();
        await _uow.PasswordResetTokens.AddAsync(new PasswordResetToken
        {
            UserId = user.Id,
            TokenHash = _jwtService.HashToken(tokenPlain),
            ExpiresAt = DateTime.UtcNow.AddHours(1),
        });
        await _uow.SaveChangesAsync();

        var link = $"{AppDeepLinkBase}/reset-password?token={Uri.EscapeDataString(tokenPlain)}";
        await _emailService.SendPasswordResetAsync(user.Email, user.FullName, link);
    }

    public async Task ResetPasswordAsync(ResetPasswordRequest request)
    {
        var tokenHash = _jwtService.HashToken(request.Token);
        var stored = await _uow.PasswordResetTokens.FirstOrDefaultAsync(t => t.TokenHash == tokenHash);

        if (stored == null || !stored.IsValid)
            throw new AppException("رابط إعادة التعيين غير صالح أو منتهي الصلاحية.");

        var user = await _uow.Users.GetByIdAsync(stored.UserId) ?? throw new NotFoundException("المستخدم");
        user.PasswordHash = _passwordHasher.Hash(request.NewPassword);
        _uow.Users.Update(user);

        stored.UsedAt = DateTime.UtcNow;
        _uow.PasswordResetTokens.Update(stored);

        // إبطال كل جلسات الدخول الحالية (Refresh Tokens) فور تغيير كلمة المرور — إجراء أمني قياسي
        // يمنع أي جهاز مسروق سابقًا من الاستمرار بالوصول بعد أن يستعيد المستخدم السيطرة على حسابه.
        var activeSessions = await _uow.RefreshTokens.FindAsync(t => t.UserId == user.Id && t.RevokedAt == null);
        foreach (var session in activeSessions)
        {
            session.RevokedAt = DateTime.UtcNow;
            _uow.RefreshTokens.Update(session);
        }

        await _uow.SaveChangesAsync();
    }

    private async Task<AuthResponse> IssueTokensAsync(User user)
    {
        var tokens = _jwtService.GenerateTokens(user);

        var refreshEntity = new RefreshToken
        {
            UserId = user.Id,
            TokenHash = _jwtService.HashToken(tokens.RefreshTokenPlain),
            ExpiresAt = DateTime.UtcNow.AddDays(30),
        };
        await _uow.RefreshTokens.AddAsync(refreshEntity);
        await _uow.SaveChangesAsync();

        var profile = new UserProfileDto(
            user.Id, user.FullName, user.Email, user.University, user.Major,
            user.AvatarUrl, user.ThemePreference.ToString().ToLower());

        return new AuthResponse(tokens.AccessToken, tokens.RefreshTokenPlain, tokens.AccessTokenExpiresAt, profile);
    }

    private static string GenerateSecureToken() => Convert.ToBase64String(RandomNumberGenerator.GetBytes(48));
}
