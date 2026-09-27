namespace EduSpirit.Domain.Common;

/// <summary>
/// كل كيان في النظام يرث من هذا الأساس: معرّف GUID (لمنع تخمين الـ IDs / IDOR)،
/// وطابع زمني للإنشاء والتعديل، ودعم الحذف الناعم (Soft Delete).
/// </summary>
public abstract class BaseEntity
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    public bool IsDeleted { get; set; } = false;
}
