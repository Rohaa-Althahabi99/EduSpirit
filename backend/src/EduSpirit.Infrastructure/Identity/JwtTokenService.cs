using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using EduSpirit.Application.Interfaces;
using EduSpirit.Domain.Entities;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;

namespace EduSpirit.Infrastructure.Identity;

public class JwtSettings
{
    public string SecretKey { get; set; } = string.Empty;
    public string Issuer { get; set; } = string.Empty;
    public string Audience { get; set; } = string.Empty;
    public int AccessTokenMinutes { get; set; } = 15;
}

public class JwtTokenService : IJwtTokenService
{
    private readonly JwtSettings _settings;

    public JwtTokenService(IConfiguration configuration)
    {
        _settings = configuration.GetSection("Jwt").Get<JwtSettings>()
                    ?? throw new InvalidOperationException("إعدادات Jwt غير موجودة في appsettings.json");
    }

    public TokenPair GenerateTokens(User user)
    {
        var expiresAt = DateTime.UtcNow.AddMinutes(_settings.AccessTokenMinutes);

        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new Claim(JwtRegisteredClaimNames.Email, user.Email),
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
        };

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_settings.SecretKey));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: _settings.Issuer,
            audience: _settings.Audience,
            claims: claims,
            expires: expiresAt,
            signingCredentials: creds);

        var accessToken = new JwtSecurityTokenHandler().WriteToken(token);
        var refreshTokenPlain = GenerateSecureRandomToken();

        return new TokenPair(accessToken, refreshTokenPlain, expiresAt);
    }

    public string HashToken(string tokenPlain)
    {
        // SHA-256 كافٍ هنا (وليس BCrypt) لأن الـ Refresh Token عشوائي عالي الإنتروبيا أصلًا
        // وليس كلمة مرور يختارها بشر، فلا حاجة لإبطاء الهجمات بالـ Salt/Work Factor.
        var bytes = Encoding.UTF8.GetBytes(tokenPlain);
        var hash = SHA256.HashData(bytes);
        return Convert.ToBase64String(hash);
    }

    public Guid? ValidateAccessTokenAndGetUserId(string accessToken)
    {
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_settings.SecretKey));
        var handler = new JwtSecurityTokenHandler();

        try
        {
            var principal = handler.ValidateToken(accessToken, new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidIssuer = _settings.Issuer,
                ValidateAudience = true,
                ValidAudience = _settings.Audience,
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = key,
                ValidateLifetime = true,
                ClockSkew = TimeSpan.FromSeconds(30),
            }, out _);

            var sub = principal.FindFirst(JwtRegisteredClaimNames.Sub)?.Value;
            return sub != null ? Guid.Parse(sub) : null;
        }
        catch
        {
            return null;
        }
    }

    private static string GenerateSecureRandomToken()
    {
        var bytes = RandomNumberGenerator.GetBytes(64);
        return Convert.ToBase64String(bytes);
    }
}
