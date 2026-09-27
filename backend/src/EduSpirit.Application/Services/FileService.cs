using EduSpirit.Application.DTOs;
using EduSpirit.Application.Exceptions;
using EduSpirit.Application.Interfaces;
using EduSpirit.Domain.Entities;

namespace EduSpirit.Application.Services;

public class FileService
{
    private readonly IUnitOfWork _uow;
    private readonly ICurrentUserService _currentUser;
    private readonly IFileStorageService _storage;

    // القائمة البيضاء للامتدادات المسموحة فقط — أي شيء غيرها يُرفض فورًا (مثل .exe, .php, .js).
    private static readonly Dictionary<string, byte[][]> AllowedTypes = new()
    {
        [".pdf"] = new[] { new byte[] { 0x25, 0x50, 0x44, 0x46 } },                 // %PDF
        [".png"] = new[] { new byte[] { 0x89, 0x50, 0x4E, 0x47 } },                 // PNG
        [".jpg"] = new[] { new byte[] { 0xFF, 0xD8, 0xFF } },
        [".jpeg"] = new[] { new byte[] { 0xFF, 0xD8, 0xFF } },
        [".docx"] = new[] { new byte[] { 0x50, 0x4B, 0x03, 0x04 } },                // ZIP-based (Office)
        [".pptx"] = new[] { new byte[] { 0x50, 0x4B, 0x03, 0x04 } },
        [".xlsx"] = new[] { new byte[] { 0x50, 0x4B, 0x03, 0x04 } },
    };

    private const long MaxFileSizeBytes = 25 * 1024 * 1024; // 25MB

    public FileService(IUnitOfWork uow, ICurrentUserService currentUser, IFileStorageService storage)
    {
        _uow = uow;
        _currentUser = currentUser;
        _storage = storage;
    }

    public async Task<StoredFileDto> UploadAsync(
        Stream fileStream, string originalFileName, string contentType, long sizeBytes,
        string ownerEntityType, Guid? ownerEntityId)
    {
        if (sizeBytes <= 0 || sizeBytes > MaxFileSizeBytes)
            throw new AppException("حجم الملف يجب ألّا يتجاوز 25 ميجابايت.");

        var extension = Path.GetExtension(originalFileName).ToLowerInvariant();
        if (!AllowedTypes.TryGetValue(extension, out var validSignatures))
            throw new AppException("نوع الملف غير مدعوم. الأنواع المسموحة: PDF, Word, PowerPoint, Excel, صور.");

        // فحص التوقيع الحقيقي للملف (Magic Number) — لا نثق فقط بامتداد الاسم، لأن
        // مهاجمًا قد يسمّي ملف .exe باسم .pdf لتجاوز الفحص السطحي.
        var header = new byte[8];
        var bytesRead = await fileStream.ReadAsync(header.AsMemory(0, 8));
        fileStream.Position = 0;

        var matchesSignature = validSignatures.Any(sig =>
            bytesRead >= sig.Length && header.Take(sig.Length).SequenceEqual(sig));

        if (!matchesSignature)
            throw new AppException("محتوى الملف لا يطابق نوعه المعلَن — تم رفض الرفع لأسباب أمنية.");

        var saved = await _storage.SaveAsync(fileStream, originalFileName, contentType);

        var entity = new StoredFile
        {
            UserId = _currentUser.UserId,
            OwnerEntityType = ownerEntityType,
            OwnerEntityId = ownerEntityId,
            StoredFileName = saved.StoredFileName,
            OriginalFileName = SanitizeDisplayName(originalFileName),
            ContentType = contentType,
            SizeBytes = sizeBytes,
            StorageUrl = saved.StorageUrl,
        };

        await _uow.StoredFiles.AddAsync(entity);
        await _uow.SaveChangesAsync();

        return ToDto(entity);
    }

    public async Task<List<StoredFileDto>> GetForEntityAsync(string ownerEntityType, Guid ownerEntityId)
    {
        var files = await _uow.StoredFiles.FindAsync(f =>
            f.UserId == _currentUser.UserId && f.OwnerEntityType == ownerEntityType && f.OwnerEntityId == ownerEntityId);
        return files.OrderByDescending(f => f.CreatedAt).Select(ToDto).ToList();
    }

    public async Task DeleteAsync(Guid fileId)
    {
        var file = await _uow.StoredFiles.GetByIdAsync(fileId) ?? throw new NotFoundException("الملف");
        if (file.UserId != _currentUser.UserId) throw new ForbiddenAppException();

        await _storage.DeleteAsync(file.StoredFileName);
        _uow.StoredFiles.Remove(file);
        await _uow.SaveChangesAsync();
    }

    /// <summary>يزيل أي محارف قد تُستغل في هجمات XSS لو عُرض الاسم لاحقًا داخل صفحة ويب (Admin Portal مثلًا).</summary>
    private static string SanitizeDisplayName(string fileName)
    {
        var invalidChars = Path.GetInvalidFileNameChars().Concat(new[] { '<', '>', '"', '\'' }).ToArray();
        var cleaned = new string(fileName.Where(c => !invalidChars.Contains(c)).ToArray());
        return cleaned.Length > 200 ? cleaned[..200] : cleaned;
    }

    private static StoredFileDto ToDto(StoredFile f) =>
        new(f.Id, f.OriginalFileName, f.ContentType, f.SizeBytes, f.StorageUrl, f.CreatedAt);
}
