namespace EduSpirit.Application.DTOs;

public record MarkAttendanceRequest(Guid CourseId, DateOnly SessionDate, string Status);

public record CourseAttendanceStatsDto(
    Guid CourseId,
    string CourseName,
    int TotalSessions,
    int PresentCount,
    int AbsentCount,
    int LateCount,
    double AttendancePercentage
);
