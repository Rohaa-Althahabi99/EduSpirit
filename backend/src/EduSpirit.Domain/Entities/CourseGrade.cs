namespace EduSpirit.Domain.Entities;

public class CourseGrade
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid UserId { get; set; }
    public User? User { get; set; }
    public Guid CourseId { get; set; }
    public Course? Course { get; set; }

    public string Semester { get; set; } = string.Empty;
    public string? LetterGrade { get; set; }
    public decimal? GradePoints { get; set; } // مثال: 4.00 على مقياس 4
    public int CreditHours { get; set; } = 3;
}
