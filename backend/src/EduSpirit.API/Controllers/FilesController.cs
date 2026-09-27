using EduSpirit.Application.DTOs;
using EduSpirit.Application.Exceptions;
using EduSpirit.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EduSpirit.API.Controllers;

[ApiController]
[Route("api/v1/files")]
[Authorize]
public class FilesController : ControllerBase
{
    private readonly FileService _fileService;
    public FilesController(FileService fileService) => _fileService = fileService;

    [HttpPost("upload")]
    [RequestSizeLimit(30_000_000)] // ~30MB على مستوى الـ HTTP قبل حتى وصول الطلب لمنطق التحقق
    public async Task<ActionResult<StoredFileDto>> Upload(
        IFormFile file, [FromForm] string ownerEntityType, [FromForm] Guid? ownerEntityId)
    {
        if (file == null || file.Length == 0)
            throw new AppException("لم يتم إرفاق أي ملف.");

        await using var stream = file.OpenReadStream();
        var result = await _fileService.UploadAsync(
            stream, file.FileName, file.ContentType, file.Length, ownerEntityType, ownerEntityId);

        return Ok(result);
    }

    [HttpGet("by-entity/{ownerEntityType}/{ownerEntityId:guid}")]
    public async Task<ActionResult<List<StoredFileDto>>> GetForEntity(string ownerEntityType, Guid ownerEntityId)
        => Ok(await _fileService.GetForEntityAsync(ownerEntityType, ownerEntityId));

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        await _fileService.DeleteAsync(id);
        return NoContent();
    }
}
