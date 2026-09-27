namespace EduSpirit.Application.DTOs;

public record CreateExamRequest(
    Guid CourseId,
    string ExamType,
    DateTime ExamDate,
    string? HallLocation,
    string? Instructions,
    string? IncludedChapters,
    string? ExcludedChapters,
    string? ImportantTopics,
    string? ProfessorNotes,
    byte Difficulty,
    byte Priority
);

public record ExamDto(
    Guid Id,
    string CourseName,
    string ExamType,
    DateTime ExamDate,
    int DaysRemaining,
    string? HallLocation,
    string? Instructions,
    string? IncludedChapters,
    string? ExcludedChapters,
    string? ImportantTopics,
    string? ProfessorNotes,
    byte Difficulty,
    byte Priority,
    List<ExamChecklistItemDto> Checklist
);

public record ExamChecklistItemDto(Guid Id, string Content, bool IsDone);

public record AddChecklistItemRequest(string Content);
