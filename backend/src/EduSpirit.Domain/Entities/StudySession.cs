namespace EduSpirit.Domain.Entities;

public class StudySession
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid UserId { get; set; }
    public User? User { get; set; }
    public Guid? CourseId { get; set; }
    public Course? Course { get; set; }

    public string Mode { get; set; } = "pomodoro"; // pomodoro|deep_work
    public int DurationMinutes { get; set; }
    public DateTime StartedAt { get; set; }
    public DateTime? EndedAt { get; set; }
}

public class StudyStreak
{
    public Guid UserId { get; set; } // Primary Key = UserId
    public User? User { get; set; }
    public int CurrentStreak { get; set; }
    public int LongestStreak { get; set; }
    public DateOnly? LastStudyDate { get; set; }
}
