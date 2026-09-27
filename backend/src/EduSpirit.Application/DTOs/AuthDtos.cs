using System.ComponentModel.DataAnnotations;

namespace EduSpirit.Application.DTOs;

public record RegisterRequest(
    [Required, StringLength(150, MinimumLength = 2)] string FullName,
    [Required, EmailAddress] string Email,
    [Required, MinLength(8)] string Password
);

public record LoginRequest(
    [ Required, EmailAddress] string Email,
    [Required] string Password
);

public record RefreshRequest([property: Required] string RefreshToken);

public record AuthResponse(
    string AccessToken,
    string RefreshToken,
    DateTime AccessTokenExpiresAt,
    UserProfileDto User
);

public record UserProfileDto(
    Guid Id,
    string FullName,
    string Email,
    string? University,
    string? Major,
    string? AvatarUrl,
    string ThemePreference
);
