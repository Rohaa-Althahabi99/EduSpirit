using EduSpirit.Domain.Common;

namespace EduSpirit.Domain.Entities;

public class Assignment : BaseEntity
{
    public Guid UserId { get; set; }
    public User? User { get; set; }

    public Guid? CourseId { get; set; }
    public Course? Course { get; set; }

    public string Title { get; set; } = string.Empty;
    public string AssignmentType { get; set; } = "homework"; // assignment|report|homework|project
    public string? Description { get; set; }
    public DateTime DueDate { get; set; }
    public byte Priority { get; set; } = 3;
    public byte ProgressPercent { get; set; } = 0;
    public string Status { get; set; } = "pending"; // pending|in_progress|submitted|graded
}
