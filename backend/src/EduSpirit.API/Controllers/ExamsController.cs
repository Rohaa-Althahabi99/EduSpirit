using EduSpirit.Application.DTOs;
using EduSpirit.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EduSpirit.API.Controllers;

[ApiController]
[Route("api/v1/exams")]
[Authorize]
public class ExamsController : ControllerBase
{
    private readonly ExamService _examService;
    public ExamsController(ExamService examService) => _examService = examService;

    [HttpGet("upcoming")]
    public async Task<ActionResult<List<ExamDto>>> GetUpcoming() => Ok(await _examService.GetUpcomingAsync());

    [HttpPost]
    public async Task<ActionResult<ExamDto>> Create([FromBody] CreateExamRequest request)
        => Ok(await _examService.CreateAsync(request));

    [HttpPost("{examId:guid}/checklist")]
    public async Task<ActionResult<ExamChecklistItemDto>> AddChecklistItem(Guid examId, [FromBody] AddChecklistItemRequest request)
        => Ok(await _examService.AddChecklistItemAsync(examId, request));

    [HttpPatch("checklist/{itemId:guid}")]
    public async Task<IActionResult> ToggleChecklistItem(Guid itemId, [FromQuery] bool isDone)
    {
        await _examService.ToggleChecklistItemAsync(itemId, isDone);
        return NoContent();
    }
}
