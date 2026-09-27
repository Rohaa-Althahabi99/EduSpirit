namespace EduSpirit.Application.DTOs;

public record CreateAssignmentRequest(
    string Title,
    Guid? CourseId,
    string AssignmentType,
    string? Description,
    DateTime DueDate,
    byte Priority
);

public record UpdateAssignmentProgressRequest(byte ProgressPercent, string Status);

public record AssignmentDto(
    Guid Id,
    string Title,
    string? CourseName,
    string AssignmentType,
    string? Description,
    DateTime DueDate,
    byte Priority,
    byte ProgressPercent,
    string Status
);
