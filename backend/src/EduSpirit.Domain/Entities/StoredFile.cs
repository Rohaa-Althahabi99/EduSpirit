namespace EduSpirit.Domain.Entities;

public class StoredFile
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid UserId { get; set; }
    public User? User { get; set; }

    public string OwnerEntityType { get; set; } = string.Empty; // assignment|note|project|exam
    public Guid? OwnerEntityId { get; set; }

    public string StoredFileName { get; set; } = string.Empty;   // اسم عشوائي على القرص (وليس اسم المستخدم الأصلي)
    public string OriginalFileName { get; set; } = string.Empty;
    public string ContentType { get; set; } = string.Empty;
    public long SizeBytes { get; set; }
    public string StorageUrl { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
