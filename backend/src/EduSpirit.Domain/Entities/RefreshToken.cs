namespace EduSpirit.Domain.Entities;

/// <summary>
/// يُخزَّن هاش الـ Refresh Token فقط (وليس القيمة الفعلية) — بحيث لو تسرّبت قاعدة
/// البيانات لا يستطيع أحد استخدام التوكنات مباشرة. مطابقة القيمة تتم بمقارنة الهاش.
/// </summary>
public class RefreshToken
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid UserId { get; set; }
    public User? User { get; set; }

    public string TokenHash { get; set; } = string.Empty;
    public DateTime ExpiresAt { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? RevokedAt { get; set; }
    public string? ReplacedByHash { get; set; }
    public string? DeviceInfo { get; set; }

    public bool IsActive => RevokedAt == null && DateTime.UtcNow < ExpiresAt;
}
