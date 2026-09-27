namespace EduSpirit.Domain.Entities;

public class AttendanceRecord
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid UserId { get; set; }
    public User? User { get; set; }

    public Guid CourseId { get; set; }
    public Course? Course { get; set; }

    public DateOnly SessionDate { get; set; }
    public string Status { get; set; } = "present"; // present|absent|late
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
