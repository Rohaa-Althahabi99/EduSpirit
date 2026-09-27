using EduSpirit.Domain.Entities;

namespace EduSpirit.Application.Interfaces;

/// <summary>
/// يجمّع كل المستودعات ويضمن أن التغييرات على أكثر من كيان تُحفظ كمعاملة واحدة (Transaction)
/// عبر استدعاء SaveChangesAsync مرة واحدة فقط.
/// </summary>
public interface IUnitOfWork
{
    IGenericRepository<User> Users { get; }
    IGenericRepository<RefreshToken> RefreshTokens { get; }
    IGenericRepository<Course> Courses { get; }
    IGenericRepository<TimetableEntry> TimetableEntries { get; }
    IGenericRepository<Exam> Exams { get; }
    IGenericRepository<ExamChecklistItem> ExamChecklistItems { get; }
    IGenericRepository<Assignment> Assignments { get; }
    IGenericRepository<Project> Projects { get; }
    IGenericRepository<ProjectMember> ProjectMembers { get; }
    IGenericRepository<ProjectTask> ProjectTasks { get; }
    IGenericRepository<ProjectMilestone> ProjectMilestones { get; }
    IGenericRepository<AttendanceRecord> AttendanceRecords { get; }
    IGenericRepository<StudySession> StudySessions { get; }
    IGenericRepository<StudyStreak> StudyStreaks { get; }
    IGenericRepository<Note> Notes { get; }
    IGenericRepository<Notification> Notifications { get; }
    IGenericRepository<CourseGrade> CourseGrades { get; }
    IGenericRepository<StoredFile> StoredFiles { get; }
    IGenericRepository<PasswordResetToken> PasswordResetTokens { get; }
    IGenericRepository<EmailVerificationToken> EmailVerificationTokens { get; }

    Task<int> SaveChangesAsync();
}
