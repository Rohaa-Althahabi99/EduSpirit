namespace EduSpirit.Application.DTOs;

public record AddGradeRequest(Guid CourseId, string Semester, string LetterGrade, decimal GradePoints, int CreditHours);

public record GpaResponse(
    decimal SemesterGpa,
    decimal OverallGpa,
    int TotalCreditHours,
    List<SemesterGpaDto> BySemester
);

public record SemesterGpaDto(string Semester, decimal Gpa, int CreditHours);

public record StatisticsResponse(
    int TotalStudyMinutesThisWeek,
    int CompletedAssignmentsCount,
    int PendingAssignmentsCount,
    double OverallAttendancePercentage,
    List<CourseAttendanceStatsDto> AttendanceByCourse
);
