namespace EduSpirit.Application.DTOs;

public record DashboardResponse(
    string GreetingName,
    List<TimetableEntryDto> TodaySchedule,
    ExamCountdownDto? NextExam,
    double AttendancePercentage,
    int PendingTasksCount
);

public record ExamCountdownDto(
    Guid ExamId,
    string CourseName,
    string ExamType,
    DateTime ExamDate,
    int DaysRemaining,
    string? HallLocation
);
