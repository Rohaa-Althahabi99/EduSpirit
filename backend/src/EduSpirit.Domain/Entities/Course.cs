using EduSpirit.Domain.Common;

namespace EduSpirit.Domain.Entities;

public class Course : BaseEntity
{
    public Guid UserId { get; set; }
    public User? User { get; set; }

    public string Name { get; set; } = string.Empty;
    public string? Code { get; set; }
    public string? ProfessorName { get; set; }
    public string ColorHex { get; set; } = "#2F6FED";
    public int CreditHours { get; set; } = 3;
    public string? Semester { get; set; }

    public ICollection<TimetableEntry> TimetableEntries { get; set; } = new List<TimetableEntry>();
}
