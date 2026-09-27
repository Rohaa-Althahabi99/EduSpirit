using EduSpirit.Application.Interfaces;
using Google.Apis.Auth;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace EduSpirit.Infrastructure.Services;

public class GoogleTokenValidator : IGoogleTokenValidator
{
    private readonly string _clientId;
    private readonly ILogger<GoogleTokenValidator> _logger;

    public GoogleTokenValidator(IConfiguration configuration, ILogger<GoogleTokenValidator> logger)
    {
        _clientId = configuration["GoogleAuth:ClientId"] ?? string.Empty;
        _logger = logger;
    }

    public async Task<GoogleUserInfo?> ValidateAsync(string idToken)
    {
        try
        {
            // GoogleJsonWebSignature.ValidateAsync يتحقق من التوقيع والصلاحية والجمهور (Audience)
            // مباشرة مع مفاتيح Google العامة — لا نثق بأي بيانات مُرسَلة من العميل بدون هذا التحقق.
            var payload = await GoogleJsonWebSignature.ValidateAsync(idToken, new GoogleJsonWebSignature.ValidationSettings
            {
                Audience = new[] { _clientId },
            });

            if (!payload.EmailVerified) return null;

            return new GoogleUserInfo(payload.Email, payload.Name ?? payload.Email, payload.Picture);
        }
        catch (InvalidJwtException ex)
        {
            _logger.LogWarning(ex, "توكن Google غير صالح");
            return null;
        }
    }
}
