using EduSpirit.Application.DTOs;
using EduSpirit.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EduSpirit.API.Controllers;

[ApiController]
[Route("api/v1/gpa")]
[Authorize]
public class GpaController : ControllerBase
{
    private readonly GpaService _gpaService;
    public GpaController(GpaService gpaService) => _gpaService = gpaService;

    [HttpGet]
    public async Task<ActionResult<GpaResponse>> Get() => Ok(await _gpaService.CalculateAsync());

    [HttpPost("grades")]
    public async Task<IActionResult> AddGrade([FromBody] AddGradeRequest request)
    {
        await _gpaService.AddGradeAsync(request);
        return NoContent();
    }
}

[ApiController]
[Route("api/v1/statistics")]
[Authorize]
public class StatisticsController : ControllerBase
{
    private readonly StatisticsService _statisticsService;
    public StatisticsController(StatisticsService statisticsService) => _statisticsService = statisticsService;

    [HttpGet]
    public async Task<ActionResult<StatisticsResponse>> Get() => Ok(await _statisticsService.BuildAsync());
}
