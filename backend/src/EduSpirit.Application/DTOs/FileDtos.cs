namespace EduSpirit.Application.DTOs;

public record StoredFileDto(Guid Id, string OriginalFileName, string ContentType, long SizeBytes, string StorageUrl, DateTime CreatedAt);
