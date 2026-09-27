using EduSpirit.Application.DTOs;
using EduSpirit.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EduSpirit.API.Controllers;

[ApiController]
[Route("api/v1/attendance")]
[Authorize]
public class AttendanceController : ControllerBase
{
    private readonly AttendanceService _attendanceService;
    public AttendanceController(AttendanceService attendanceService) => _attendanceService = attendanceService;

    [HttpPost]
    public async Task<IActionResult> Mark([FromBody] MarkAttendanceRequest request)
    {
        await _attendanceService.MarkAsync(request);
        return NoContent();
    }

    [HttpGet("stats")]
    public async Task<ActionResult<List<CourseAttendanceStatsDto>>> GetStats()
        => Ok(await _attendanceService.GetStatsAsync());
}
