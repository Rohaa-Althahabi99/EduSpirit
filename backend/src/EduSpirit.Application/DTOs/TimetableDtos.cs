using System.ComponentModel.DataAnnotations;

namespace EduSpirit.Application.DTOs;

public record CreateTimetableEntryRequest(
    [Required, StringLength(200)] string Title,
    Guid? CourseId,
    [property: Required] string EntryType,   // lecture|online|lab|workshop|seminar|custom
    string? Location,
    string? OnlineLink,
    byte? DayOfWeek,
    [property: Required] TimeOnly StartTime,
    [property: Required] TimeOnly EndTime,
    [property: Required] DateOnly StartDate,
    DateOnly? EndDate,
    bool IsRecurring,
    string? ColorHex
);

public record TimetableEntryDto(
    Guid Id,
    string Title,
    string EntryType,
    string? CourseName,
    string? Location,
    string? OnlineLink,
    byte? DayOfWeek,
    TimeOnly StartTime,
    TimeOnly EndTime,
    string ColorHex
);
