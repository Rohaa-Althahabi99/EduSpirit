using EduSpirit.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace EduSpirit.Infrastructure.Persistence;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<User> Users => Set<User>();
    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
    public DbSet<Course> Courses => Set<Course>();
    public DbSet<TimetableEntry> TimetableEntries => Set<TimetableEntry>();
    public DbSet<Exam> Exams => Set<Exam>();
    public DbSet<ExamChecklistItem> ExamChecklistItems => Set<ExamChecklistItem>();
    public DbSet<Assignment> Assignments => Set<Assignment>();
    public DbSet<Project> Projects => Set<Project>();
    public DbSet<ProjectMember> ProjectMembers => Set<ProjectMember>();
    public DbSet<ProjectTask> ProjectTasks => Set<ProjectTask>();
    public DbSet<ProjectMilestone> ProjectMilestones => Set<ProjectMilestone>();
    public DbSet<AttendanceRecord> AttendanceRecords => Set<AttendanceRecord>();
    public DbSet<StudySession> StudySessions => Set<StudySession>();
    public DbSet<StudyStreak> StudyStreaks => Set<StudyStreak>();
    public DbSet<Note> Notes => Set<Note>();
    public DbSet<Notification> Notifications => Set<Notification>();
    public DbSet<CourseGrade> CourseGrades => Set<CourseGrade>();
    public DbSet<StoredFile> StoredFiles => Set<StoredFile>();
    public DbSet<PasswordResetToken> PasswordResetTokens => Set<PasswordResetToken>();
    public DbSet<EmailVerificationToken> EmailVerificationTokens => Set<EmailVerificationToken>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly);

        modelBuilder.Entity<StudyStreak>().HasKey(s => s.UserId);
        modelBuilder.Entity<AttendanceRecord>()
            .HasIndex(a => new { a.UserId, a.CourseId, a.SessionDate }).IsUnique();

        modelBuilder.Entity<Exam>()
            .HasMany(e => e.ChecklistItems).WithOne(c => c.Exam)
            .HasForeignKey(c => c.ExamId).OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<Project>()
            .HasMany(p => p.Members).WithOne(m => m.Project)
            .HasForeignKey(m => m.ProjectId).OnDelete(DeleteBehavior.Cascade);
        modelBuilder.Entity<Project>()
            .HasMany(p => p.Tasks).WithOne(t => t.Project)
            .HasForeignKey(t => t.ProjectId).OnDelete(DeleteBehavior.Cascade);
        modelBuilder.Entity<Project>()
            .HasMany(p => p.Milestones).WithOne(m => m.Project)
            .HasForeignKey(m => m.ProjectId).OnDelete(DeleteBehavior.Cascade);
        modelBuilder.Entity<ProjectMember>().HasIndex(m => new { m.ProjectId, m.UserId }).IsUnique();

        modelBuilder.Entity<Exam>()
            .HasOne(e => e.Course).WithMany().HasForeignKey(e => e.CourseId).OnDelete(DeleteBehavior.Cascade);
        modelBuilder.Entity<Assignment>()
            .HasOne(a => a.Course).WithMany().HasForeignKey(a => a.CourseId).OnDelete(DeleteBehavior.SetNull);
        modelBuilder.Entity<AttendanceRecord>()
            .HasOne(a => a.Course).WithMany().HasForeignKey(a => a.CourseId).OnDelete(DeleteBehavior.Cascade);
        modelBuilder.Entity<Note>()
            .HasOne(n => n.Course).WithMany().HasForeignKey(n => n.CourseId).OnDelete(DeleteBehavior.SetNull);
        modelBuilder.Entity<CourseGrade>()
            .Property(g => g.GradePoints).HasPrecision(4, 2);
        modelBuilder.Entity<CourseGrade>()
            .HasOne(g => g.Course).WithMany().HasForeignKey(g => g.CourseId).OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<Project>()
            .HasOne(p => p.Course).WithMany().HasForeignKey(p => p.CourseId).OnDelete(DeleteBehavior.SetNull);
        modelBuilder.Entity<StudySession>()
            .HasOne(s => s.Course).WithMany().HasForeignKey(s => s.CourseId).OnDelete(DeleteBehavior.SetNull);

        // مهم جدًا: كيانات مثل Exam/Assignment/AttendanceRecord/CourseGrade تملك مسارَين للوصول
        // لـ User (مباشرة عبر UserId، وبالتبعية عبر CourseId → Course → User). لو تركنا الاثنين
        // Cascade فسيرفض SQL Server إنشاء الجدول بخطأ "may cause cycles or multiple cascade paths".
        // الحل: نُبقي الحذف المتتالي عبر المسار الوحيد (Course) ونجعل الرابط المباشر Restrict.
        modelBuilder.Entity<Exam>()
            .HasOne(e => e.User).WithMany().HasForeignKey(e => e.UserId).OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<Assignment>()
            .HasOne(a => a.User).WithMany().HasForeignKey(a => a.UserId).OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<AttendanceRecord>()
            .HasOne(a => a.User).WithMany().HasForeignKey(a => a.UserId).OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<Note>()
            .HasOne(n => n.User).WithMany().HasForeignKey(n => n.UserId).OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<CourseGrade>()
            .HasOne(g => g.User).WithMany().HasForeignKey(g => g.UserId).OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<StudySession>()
            .HasOne(s => s.User).WithMany().HasForeignKey(s => s.UserId).OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<Project>()
            .HasOne(p => p.OwnerUser).WithMany().HasForeignKey(p => p.OwnerUserId).OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<StoredFile>()
            .HasOne(f => f.User).WithMany().HasForeignKey(f => f.UserId).OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<ProjectTask>()
            .HasOne<User>().WithMany().HasForeignKey(t => t.AssignedToUserId).OnDelete(DeleteBehavior.SetNull);

        // فلتر عام: أي كيان يحتوي IsDeleted لا يظهر أبدًا في الاستعلامات الافتراضية
        // (Soft Delete شفاف بالكامل لبقية طبقات النظام).
        modelBuilder.Entity<User>().HasQueryFilter(u => !u.IsDeleted);
        modelBuilder.Entity<Course>().HasQueryFilter(c => !c.IsDeleted);
        modelBuilder.Entity<TimetableEntry>().HasQueryFilter(t => !t.IsDeleted);
        modelBuilder.Entity<Exam>().HasQueryFilter(e => !e.IsDeleted);
        modelBuilder.Entity<Assignment>().HasQueryFilter(a => !a.IsDeleted);
        modelBuilder.Entity<Project>().HasQueryFilter(p => !p.IsDeleted);
        modelBuilder.Entity<Note>().HasQueryFilter(n => !n.IsDeleted);

        base.OnModelCreating(modelBuilder);
    }

    public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        foreach (var entry in ChangeTracker.Entries<Domain.Common.BaseEntity>())
        {
            if (entry.State == EntityState.Modified)
                entry.Entity.UpdatedAt = DateTime.UtcNow;
        }
        return base.SaveChangesAsync(cancellationToken);
    }
}
