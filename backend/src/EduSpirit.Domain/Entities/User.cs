using EduSpirit.Domain.Common;
using EduSpirit.Domain.Enums;

namespace EduSpirit.Domain.Entities;

public class User : BaseEntity
{
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;

    /// <summary>هاش كلمة المرور فقط (BCrypt) — لا يُخزَّن نص صريح أبدًا.</summary>
    public string PasswordHash { get; set; } = string.Empty;

    public string? University { get; set; }
    public string? Major { get; set; }
    public int? AcademicYear { get; set; }
    public string? AvatarUrl { get; set; }
    public bool IsEmailVerified { get; set; }
    public AuthProvider AuthProvider { get; set; } = AuthProvider.Local;
    public ThemePreference ThemePreference { get; set; } = ThemePreference.System;
    public string LanguagePreference { get; set; } = "ar";

    public ICollection<RefreshToken> RefreshTokens { get; set; } = new List<RefreshToken>();
    public ICollection<Course> Courses { get; set; } = new List<Course>();
    public ICollection<TimetableEntry> TimetableEntries { get; set; } = new List<TimetableEntry>();
}
