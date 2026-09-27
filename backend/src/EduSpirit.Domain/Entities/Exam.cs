using EduSpirit.Domain.Common;

namespace EduSpirit.Domain.Entities;

public class Exam : BaseEntity
{
    public Guid UserId { get; set; }
    public User? User { get; set; }

    public Guid CourseId { get; set; }
    public Course? Course { get; set; }

    public string ExamType { get; set; } = "quiz"; // quiz|midterm|final|practical
    public DateTime ExamDate { get; set; }
    public string? HallLocation { get; set; }
    public string? Instructions { get; set; }
    public string? IncludedChapters { get; set; }
    public string? ExcludedChapters { get; set; }
    public string? ImportantTopics { get; set; }
    public string? ProfessorNotes { get; set; }
    public byte Difficulty { get; set; } = 3;   // 1..5
    public byte Priority { get; set; } = 3;     // 1..5

    public ICollection<ExamChecklistItem> ChecklistItems { get; set; } = new List<ExamChecklistItem>();
}

public class ExamChecklistItem
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid ExamId { get; set; }
    public Exam? Exam { get; set; }
    public string Content { get; set; } = string.Empty;
    public bool IsDone { get; set; }
    public int SortOrder { get; set; }
}
