namespace EduSpirit.Application.DTOs;

public record CreateCourseRequest(string Name, string? Code, string? ProfessorName, string? ColorHex, int CreditHours, string? Semester);
public record UpdateCourseRequest(string Name, string? Code, string? ProfessorName, string? ColorHex, int CreditHours, string? Semester);

public record CourseDto(Guid Id, string Name, string? Code, string? ProfessorName, string ColorHex, int CreditHours, string? Semester);
