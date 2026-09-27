using EduSpirit.Application.Interfaces;
using EduSpirit.Domain.Entities;
using EduSpirit.Infrastructure.Persistence;

namespace EduSpirit.Infrastructure.Repositories;

public class UnitOfWork : IUnitOfWork
{
    private readonly AppDbContext _context;

    public UnitOfWork(AppDbContext context)
    {
        _context = context;
        Users = new GenericRepository<User>(_context);
        RefreshTokens = new GenericRepository<RefreshToken>(_context);
        Courses = new GenericRepository<Course>(_context);
        TimetableEntries = new GenericRepository<TimetableEntry>(_context);
        Exams = new GenericRepository<Exam>(_context);
        ExamChecklistItems = new GenericRepository<ExamChecklistItem>(_context);
        Assignments = new GenericRepository<Assignment>(_context);
        Projects = new GenericRepository<Project>(_context);
        ProjectMembers = new GenericRepository<ProjectMember>(_context);
        ProjectTasks = new GenericRepository<ProjectTask>(_context);
        ProjectMilestones = new GenericRepository<ProjectMilestone>(_context);
        AttendanceRecords = new GenericRepository<AttendanceRecord>(_context);
        StudySessions = new GenericRepository<StudySession>(_context);
        StudyStreaks = new GenericRepository<StudyStreak>(_context);
        Notes = new GenericRepository<Note>(_context);
        Notifications = new GenericRepository<Notification>(_context);
        CourseGrades = new GenericRepository<CourseGrade>(_context);
        StoredFiles = new GenericRepository<StoredFile>(_context);
        PasswordResetTokens = new GenericRepository<PasswordResetToken>(_context);
        EmailVerificationTokens = new GenericRepository<EmailVerificationToken>(_context);
    }

    public IGenericRepository<User> Users { get; }
    public IGenericRepository<RefreshToken> RefreshTokens { get; }
    public IGenericRepository<Course> Courses { get; }
    public IGenericRepository<TimetableEntry> TimetableEntries { get; }
    public IGenericRepository<Exam> Exams { get; }
    public IGenericRepository<ExamChecklistItem> ExamChecklistItems { get; }
    public IGenericRepository<Assignment> Assignments { get; }
    public IGenericRepository<Project> Projects { get; }
    public IGenericRepository<ProjectMember> ProjectMembers { get; }
    public IGenericRepository<ProjectTask> ProjectTasks { get; }
    public IGenericRepository<ProjectMilestone> ProjectMilestones { get; }
    public IGenericRepository<AttendanceRecord> AttendanceRecords { get; }
    public IGenericRepository<StudySession> StudySessions { get; }
    public IGenericRepository<StudyStreak> StudyStreaks { get; }
    public IGenericRepository<Note> Notes { get; }
    public IGenericRepository<Notification> Notifications { get; }
    public IGenericRepository<CourseGrade> CourseGrades { get; }
    public IGenericRepository<StoredFile> StoredFiles { get; }
    public IGenericRepository<PasswordResetToken> PasswordResetTokens { get; }
    public IGenericRepository<EmailVerificationToken> EmailVerificationTokens { get; }

    public Task<int> SaveChangesAsync() => _context.SaveChangesAsync();
}
