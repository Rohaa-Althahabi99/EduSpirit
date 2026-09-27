using EduSpirit.Application.DTOs;
using EduSpirit.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EduSpirit.API.Controllers;

[ApiController]
[Route("api/v1/notes")]
[Authorize]
public class NotesController : ControllerBase
{
    private readonly NoteService _noteService;
    public NotesController(NoteService noteService) => _noteService = noteService;

    [HttpGet]
    public async Task<ActionResult<PagedResult<NoteDto>>> Search(
        [FromQuery] string? q, [FromQuery] int page = 1, [FromQuery] int pageSize = 20)
        => Ok(await _noteService.SearchAsync(q, new PageQuery(page, pageSize)));

    [HttpPost]
    public async Task<ActionResult<NoteDto>> Create([FromBody] CreateNoteRequest request)
        => Ok(await _noteService.CreateAsync(request));

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        await _noteService.DeleteAsync(id);
        return NoContent();
    }
}
