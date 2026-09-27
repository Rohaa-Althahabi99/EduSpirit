namespace EduSpirit.Application.Interfaces;

public record SavedFileResult(string StoredFileName, string StorageUrl);

/// <summary>
/// عزل تام عن مكان التخزين الفعلي — التنفيذ الحالي (Infrastructure) يحفظ على القرص المحلي،
/// ويمكن استبداله لاحقًا بـ Azure Blob Storage / AWS S3 بدون أي تعديل في Application أو API.
/// </summary>
public interface IFileStorageService
{
    Task<SavedFileResult> SaveAsync(Stream fileStream, string safeFileName, string contentType);
    Task DeleteAsync(string storedFileName);
    Task<Stream?> OpenReadAsync(string storedFileName);
}
