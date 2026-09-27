using EduSpirit.Application.Interfaces;
using Microsoft.Extensions.Configuration;

namespace EduSpirit.Infrastructure.Services;

public class LocalFileStorageService : IFileStorageService
{
    private readonly string _rootPath;
    private readonly string _publicBaseUrl;

    public LocalFileStorageService(IConfiguration configuration)
    {
        _rootPath = configuration["FileStorage:RootPath"] ?? "wwwroot/uploads";
        _publicBaseUrl = configuration["FileStorage:PublicBaseUrl"] ?? "/uploads";
        Directory.CreateDirectory(_rootPath);
    }

    public async Task<SavedFileResult> SaveAsync(Stream fileStream, string safeFileName, string contentType)
    {
        // اسم عشوائي كامل على القرص (وليس اسم الملف الأصلي) — يمنع Path Traversal ويمنع
        // تخمين/استبدال ملفات مستخدمين آخرين حتى لو عرف المهاجم اسم الملف الأصلي.
        var extension = Path.GetExtension(safeFileName);
        var storedFileName = $"{Guid.NewGuid():N}{extension}";
        var fullPath = Path.Combine(_rootPath, storedFileName);

        await using var output = File.Create(fullPath);
        await fileStream.CopyToAsync(output);

        return new SavedFileResult(storedFileName, $"{_publicBaseUrl}/{storedFileName}");
    }

    public Task DeleteAsync(string storedFileName)
    {
        var fullPath = Path.Combine(_rootPath, storedFileName);
        if (File.Exists(fullPath)) File.Delete(fullPath);
        return Task.CompletedTask;
    }

    public Task<Stream?> OpenReadAsync(string storedFileName)
    {
        var fullPath = Path.Combine(_rootPath, storedFileName);
        if (!File.Exists(fullPath)) return Task.FromResult<Stream?>(null);
        return Task.FromResult<Stream?>(File.OpenRead(fullPath));
    }
}
