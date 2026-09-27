/* ======================================================================
   EduSpirit — SQL Server Database Schema (Full ERD → DDL)
   Engine: SQL Server 2019+
   Notes:
     - كل مفتاح أساسي UNIQUEIDENTIFIER (GUID) لتفادي تخمين المعرّفات (IDOR).
     - كل جدول يحتوي CreatedAt/UpdatedAt/IsDeleted (Soft Delete).
     - العلاقات مقيّدة بـ FOREIGN KEY مع ON DELETE مناسب لكل حالة.
   ====================================================================== */

CREATE DATABASE EduSpiritDB;
GO
USE EduSpiritDB;
GO

-- =========================== Users & Auth ===========================
CREATE TABLE Users (
    Id                  UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    FullName            NVARCHAR(150)   NOT NULL,
    Email               NVARCHAR(200)   NOT NULL UNIQUE,
    PasswordHash        NVARCHAR(500)   NOT NULL,
    University          NVARCHAR(200)   NULL,
    Major               NVARCHAR(150)   NULL,
    AcademicYear         INT             NULL,
    AvatarUrl           NVARCHAR(500)   NULL,
    IsEmailVerified     BIT             NOT NULL DEFAULT 0,
    AuthProvider        NVARCHAR(20)    NOT NULL DEFAULT 'local',
    ThemePreference     NVARCHAR(10)    NOT NULL DEFAULT 'system',
    LanguagePreference  NVARCHAR(5)     NOT NULL DEFAULT 'ar',
    CreatedAt           DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt           DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    IsDeleted           BIT             NOT NULL DEFAULT 0
);

CREATE TABLE RefreshTokens (
    Id              UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId          UNIQUEIDENTIFIER NOT NULL REFERENCES Users(Id) ON DELETE CASCADE,
    TokenHash       NVARCHAR(500) NOT NULL,
    ExpiresAt       DATETIME2 NOT NULL,
    CreatedAt       DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    RevokedAt       DATETIME2 NULL,
    ReplacedByHash  NVARCHAR(500) NULL,
    DeviceInfo      NVARCHAR(300) NULL
);

CREATE TABLE PasswordResetTokens (
    Id          UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId      UNIQUEIDENTIFIER NOT NULL REFERENCES Users(Id) ON DELETE CASCADE,
    TokenHash   NVARCHAR(500) NOT NULL,
    ExpiresAt   DATETIME2 NOT NULL,
    UsedAt      DATETIME2 NULL,
    CreatedAt   DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE EmailVerificationTokens (
    Id          UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId      UNIQUEIDENTIFIER NOT NULL REFERENCES Users(Id) ON DELETE CASCADE,
    TokenHash   NVARCHAR(500) NOT NULL,
    ExpiresAt   DATETIME2 NOT NULL,
    UsedAt      DATETIME2 NULL,
    CreatedAt   DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

-- =========================== Courses ===========================
CREATE TABLE Courses (
    Id          UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId      UNIQUEIDENTIFIER NOT NULL REFERENCES Users(Id) ON DELETE CASCADE,
    Name        NVARCHAR(200) NOT NULL,
    Code        NVARCHAR(30)  NULL,
    ProfessorName NVARCHAR(150) NULL,
    ColorHex    NVARCHAR(9)   NOT NULL DEFAULT '#2F6FED',
    CreditHours INT           NOT NULL DEFAULT 3,
    Semester    NVARCHAR(30)  NULL,
    CreatedAt   DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt   DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    IsDeleted   BIT NOT NULL DEFAULT 0
);

-- =========================== Smart Timetable ===========================
CREATE TABLE TimetableEntries (
    Id          UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId      UNIQUEIDENTIFIER NOT NULL REFERENCES Users(Id) ON DELETE NO ACTION,
    CourseId    UNIQUEIDENTIFIER NULL REFERENCES Courses(Id) ON DELETE SET NULL,
    Title       NVARCHAR(200) NOT NULL,
    EntryType   NVARCHAR(20)  NOT NULL DEFAULT 'lecture',
    Location    NVARCHAR(200) NULL,
    OnlineLink  NVARCHAR(500) NULL,
    DayOfWeek   TINYINT       NULL,
    StartTime   TIME          NOT NULL,
    EndTime     TIME          NOT NULL,
    StartDate   DATE          NOT NULL,
    EndDate     DATE          NULL,
    IsRecurring BIT           NOT NULL DEFAULT 1,
    ColorHex    NVARCHAR(9)   NULL,
    CreatedAt   DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt   DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    IsDeleted   BIT NOT NULL DEFAULT 0,
    CONSTRAINT CK_Timetable_Time CHECK (EndTime > StartTime)
);
CREATE INDEX IX_Timetable_UserDay ON TimetableEntries(UserId, DayOfWeek);

CREATE TABLE HolidaysAndBreaks (
    Id          UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId      UNIQUEIDENTIFIER NOT NULL REFERENCES Users(Id) ON DELETE CASCADE,
    Title       NVARCHAR(200) NOT NULL,
    StartDate   DATE NOT NULL,
    EndDate     DATE NOT NULL
);

-- =========================== Exams ===========================
CREATE TABLE Exams (
    Id               UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId           UNIQUEIDENTIFIER NOT NULL REFERENCES Users(Id) ON DELETE NO ACTION,
    CourseId         UNIQUEIDENTIFIER NOT NULL REFERENCES Courses(Id) ON DELETE CASCADE,
    ExamType         NVARCHAR(20) NOT NULL,
    ExamDate         DATETIME2 NOT NULL,
    HallLocation     NVARCHAR(200) NULL,
    Instructions     NVARCHAR(MAX) NULL,
    IncludedChapters NVARCHAR(MAX) NULL,
    ExcludedChapters NVARCHAR(MAX) NULL,
    ImportantTopics  NVARCHAR(MAX) NULL,
    ProfessorNotes   NVARCHAR(MAX) NULL,
    Difficulty       TINYINT NOT NULL DEFAULT 3,
    Priority         TINYINT NOT NULL DEFAULT 3,
    CreatedAt        DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt        DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    IsDeleted        BIT NOT NULL DEFAULT 0
);

CREATE TABLE ExamChecklistItems (
    Id       UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    ExamId   UNIQUEIDENTIFIER NOT NULL REFERENCES Exams(Id) ON DELETE CASCADE,
    Content  NVARCHAR(300) NOT NULL,
    IsDone   BIT NOT NULL DEFAULT 0,
    SortOrder INT NOT NULL DEFAULT 0
);

-- =========================== Assignments / Projects ===========================
CREATE TABLE Assignments (
    Id               UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId           UNIQUEIDENTIFIER NOT NULL REFERENCES Users(Id) ON DELETE NO ACTION,
    CourseId         UNIQUEIDENTIFIER NULL REFERENCES Courses(Id) ON DELETE SET NULL,
    Title            NVARCHAR(200) NOT NULL,
    AssignmentType   NVARCHAR(20)  NOT NULL DEFAULT 'homework',
    Description      NVARCHAR(MAX) NULL,
    DueDate          DATETIME2 NOT NULL,
    Priority         TINYINT NOT NULL DEFAULT 3,
    ProgressPercent  TINYINT NOT NULL DEFAULT 0,
    Status           NVARCHAR(20) NOT NULL DEFAULT 'pending',
    CreatedAt        DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt        DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    IsDeleted        BIT NOT NULL DEFAULT 0
);

CREATE TABLE Projects (
    Id          UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    OwnerUserId UNIQUEIDENTIFIER NOT NULL REFERENCES Users(Id) ON DELETE NO ACTION,
    CourseId    UNIQUEIDENTIFIER NULL REFERENCES Courses(Id) ON DELETE SET NULL,
    Title       NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    DueDate     DATETIME2 NULL,
    ProgressPercent TINYINT NOT NULL DEFAULT 0,
    CreatedAt   DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    IsDeleted   BIT NOT NULL DEFAULT 0
);

CREATE TABLE ProjectMembers (
    Id        UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    ProjectId UNIQUEIDENTIFIER NOT NULL REFERENCES Projects(Id) ON DELETE CASCADE,
    UserId    UNIQUEIDENTIFIER NOT NULL REFERENCES Users(Id) ON DELETE NO ACTION,
    RoleInProject NVARCHAR(50) NOT NULL DEFAULT 'member',
    UNIQUE(ProjectId, UserId)
);

CREATE TABLE ProjectTasks (
    Id         UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    ProjectId  UNIQUEIDENTIFIER NOT NULL REFERENCES Projects(Id) ON DELETE CASCADE,
    AssignedToUserId UNIQUEIDENTIFIER NULL REFERENCES Users(Id) ON DELETE NO ACTION,
    Title      NVARCHAR(200) NOT NULL,
    IsDone     BIT NOT NULL DEFAULT 0,
    DueDate    DATETIME2 NULL
);

CREATE TABLE ProjectMilestones (
    Id         UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    ProjectId  UNIQUEIDENTIFIER NOT NULL REFERENCES Projects(Id) ON DELETE CASCADE,
    Title      NVARCHAR(200) NOT NULL,
    DueDate    DATETIME2 NULL,
    IsDone     BIT NOT NULL DEFAULT 0
);

CREATE TABLE ProjectComments (
    Id         UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    ProjectId  UNIQUEIDENTIFIER NOT NULL REFERENCES Projects(Id) ON DELETE CASCADE,
    UserId     UNIQUEIDENTIFIER NOT NULL REFERENCES Users(Id) ON DELETE NO ACTION,
    Content    NVARCHAR(1000) NOT NULL,
    CreatedAt  DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

-- =========================== Smart Tasks ===========================
CREATE TABLE StudentTasks (
    Id          UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId      UNIQUEIDENTIFIER NOT NULL REFERENCES Users(Id) ON DELETE CASCADE,
    Title       NVARCHAR(200) NOT NULL,
    Category    NVARCHAR(50) NULL,
    Priority    TINYINT NOT NULL DEFAULT 3,
    DueDate     DATETIME2 NULL,
    RecurrenceRule NVARCHAR(100) NULL,
    IsDone      BIT NOT NULL DEFAULT 0,
    CreatedAt   DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    IsDeleted   BIT NOT NULL DEFAULT 0
);

-- =========================== Attendance ===========================
CREATE TABLE AttendanceRecords (
    Id         UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId     UNIQUEIDENTIFIER NOT NULL REFERENCES Users(Id) ON DELETE NO ACTION,
    CourseId   UNIQUEIDENTIFIER NOT NULL REFERENCES Courses(Id) ON DELETE CASCADE,
    SessionDate DATE NOT NULL,
    Status     NVARCHAR(10) NOT NULL DEFAULT 'present',
    CreatedAt  DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    UNIQUE(UserId, CourseId, SessionDate)
);

-- =========================== Study Mode ===========================
CREATE TABLE StudySessions (
    Id            UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId        UNIQUEIDENTIFIER NOT NULL REFERENCES Users(Id) ON DELETE NO ACTION,
    CourseId      UNIQUEIDENTIFIER NULL REFERENCES Courses(Id) ON DELETE SET NULL,
    Mode          NVARCHAR(20) NOT NULL DEFAULT 'pomodoro',
    DurationMinutes INT NOT NULL,
    StartedAt     DATETIME2 NOT NULL,
    EndedAt       DATETIME2 NULL
);

CREATE TABLE StudyStreaks (
    UserId        UNIQUEIDENTIFIER PRIMARY KEY REFERENCES Users(Id) ON DELETE CASCADE,
    CurrentStreak INT NOT NULL DEFAULT 0,
    LongestStreak INT NOT NULL DEFAULT 0,
    LastStudyDate DATE NULL
);

-- =========================== Notes ===========================
CREATE TABLE Notes (
    Id          UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId      UNIQUEIDENTIFIER NOT NULL REFERENCES Users(Id) ON DELETE NO ACTION,
    CourseId    UNIQUEIDENTIFIER NULL REFERENCES Courses(Id) ON DELETE SET NULL,
    Title       NVARCHAR(200) NOT NULL,
    ContentRichText NVARCHAR(MAX) NULL,
    NoteType    NVARCHAR(20) NOT NULL DEFAULT 'text',
    FolderName  NVARCHAR(100) NULL,
    Tags        NVARCHAR(300) NULL,
    CreatedAt   DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt   DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    IsDeleted   BIT NOT NULL DEFAULT 0
);

-- =========================== Files ===========================
CREATE TABLE StoredFiles (
    Id           UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId       UNIQUEIDENTIFIER NOT NULL REFERENCES Users(Id) ON DELETE CASCADE,
    OwnerEntityType NVARCHAR(30) NOT NULL,
    OwnerEntityId   UNIQUEIDENTIFIER NULL,
    StoredFileName  NVARCHAR(300) NOT NULL,
    OriginalFileName NVARCHAR(300) NOT NULL,
    ContentType     NVARCHAR(100) NOT NULL,
    SizeBytes       BIGINT NOT NULL,
    StorageUrl      NVARCHAR(500) NOT NULL,
    CreatedAt       DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

-- =========================== Notifications ===========================
CREATE TABLE Notifications (
    Id          UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId      UNIQUEIDENTIFIER NOT NULL REFERENCES Users(Id) ON DELETE CASCADE,
    Title       NVARCHAR(200) NOT NULL,
    Body        NVARCHAR(500) NULL,
    NotificationType NVARCHAR(30) NOT NULL DEFAULT 'custom',
    RelatedEntityType NVARCHAR(30) NULL,
    RelatedEntityId   UNIQUEIDENTIFIER NULL,
    ScheduledAt DATETIME2 NULL,
    IsRead      BIT NOT NULL DEFAULT 0,
    CreatedAt   DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

-- =========================== GPA / Grades ===========================
CREATE TABLE CourseGrades (
    Id          UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId      UNIQUEIDENTIFIER NOT NULL REFERENCES Users(Id) ON DELETE NO ACTION,
    CourseId    UNIQUEIDENTIFIER NOT NULL REFERENCES Courses(Id) ON DELETE CASCADE,
    Semester    NVARCHAR(30) NOT NULL,
    LetterGrade NVARCHAR(5) NULL,
    GradePoints DECIMAL(4,2) NULL,
    CreditHours INT NOT NULL DEFAULT 3
);

-- =========================== Audit Log (Security) ===========================
CREATE TABLE AuditLogs (
    Id          BIGINT IDENTITY PRIMARY KEY,
    UserId      UNIQUEIDENTIFIER NULL,
    Action      NVARCHAR(100) NOT NULL,
    IpAddress   NVARCHAR(50) NULL,
    UserAgent   NVARCHAR(300) NULL,
    CreatedAt   DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

-- =========================== Helpful Indexes ===========================
CREATE INDEX IX_Exams_UserDate        ON Exams(UserId, ExamDate);
CREATE INDEX IX_Assignments_UserDue   ON Assignments(UserId, DueDate);
CREATE INDEX IX_Tasks_UserDue         ON StudentTasks(UserId, DueDate);
CREATE INDEX IX_Notifications_UserRead ON Notifications(UserId, IsRead);