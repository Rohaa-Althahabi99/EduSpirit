namespace EduSpirit.Application.DTOs;

public record CreateNoteRequest(string Title, string? ContentRichText, string NoteType, Guid? CourseId, string? FolderName, string? Tags);

public record NoteDto(Guid Id, string Title, string? ContentRichText, string NoteType, string? CourseName, string? FolderName, string? Tags, DateTime UpdatedAt);
