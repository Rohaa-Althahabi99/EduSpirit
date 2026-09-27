using EduSpirit.Domain.Common;

namespace EduSpirit.Domain.Entities;

public class Note : BaseEntity
{
    public Guid UserId { get; set; }
    public User? User { get; set; }
    public Guid? CourseId { get; set; }
    public Course? Course { get; set; }

    public string Title { get; set; } = string.Empty;
    public string? ContentRichText { get; set; }
    public string NoteType { get; set; } = "text"; // text|voice|drawing|pdf
    public string? FolderName { get; set; }
    public string? Tags { get; set; } // comma-separated
}
