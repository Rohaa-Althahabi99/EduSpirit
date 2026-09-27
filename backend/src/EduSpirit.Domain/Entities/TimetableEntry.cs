using EduSpirit.Domain.Common;
using EduSpirit.Domain.Enums;

namespace EduSpirit.Domain.Entities;

public class TimetableEntry : BaseEntity
{
    public Guid UserId { get; set; }
    public User? User { get; set; }

    public Guid? CourseId { get; set; }
    public Course? Course { get; set; }

    public string Title { get; set; } = string.Empty;
    public TimetableEntryType EntryType { get; set; } = TimetableEntryType.Lecture;
    public string? Location { get; set; }
    public string? OnlineLink { get; set; }

    /// <summary>1 = الأحد ... 7 = السبت (لغرض التكرار الأسبوعي).</summary>
    public byte? DayOfWeek { get; set; }

    public TimeOnly StartTime { get; set; }
    public TimeOnly EndTime { get; set; }
    public DateOnly StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
    public bool IsRecurring { get; set; } = true;
    public string? ColorHex { get; set; }
}
