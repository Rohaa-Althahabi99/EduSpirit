using System.IdentityModel.Tokens.Jwt;
using EduSpirit.Application.Interfaces;
using Microsoft.AspNetCore.Http;

namespace EduSpirit.Infrastructure.Identity;

public class CurrentUserService : ICurrentUserService
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public CurrentUserService(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    public Guid UserId
    {
        get
        {
            var sub = _httpContextAccessor.HttpContext?.User?
                .FindFirst(JwtRegisteredClaimNames.Sub)?.Value;
            return sub != null && Guid.TryParse(sub, out var id) ? id : Guid.Empty;
        }
    }

    public bool IsAuthenticated =>
        _httpContextAccessor.HttpContext?.User?.Identity?.IsAuthenticated ?? false;
}
