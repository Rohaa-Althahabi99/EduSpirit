using EduSpirit.Application.DTOs;
using EduSpirit.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EduSpirit.API.Controllers;

[ApiController]
[Route("api/v1/study")]
[Authorize]
public class StudyController : ControllerBase
{
    private readonly StudyService _studyService;
    public StudyController(StudyService studyService) => _studyService = studyService;

    [HttpPost("start")]
    public async Task<ActionResult<object>> Start([FromBody] StartStudySessionRequest request)
        => Ok(new { sessionId = await _studyService.StartSessionAsync(request) });

    [HttpPost("end")]
    public async Task<IActionResult> End([FromBody] EndStudySessionRequest request)
    {
        await _studyService.EndSessionAsync(request);
        return NoContent();
    }

    [HttpGet("streak")]
    public async Task<ActionResult<StudyStreakDto>> GetStreak() => Ok(await _studyService.GetStreakAsync());
}
