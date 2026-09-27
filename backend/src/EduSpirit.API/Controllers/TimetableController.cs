using EduSpirit.Application.DTOs;
using EduSpirit.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EduSpirit.API.Controllers;

[ApiController]
[Route("api/v1/timetable")]
[Authorize] // كل النقاط هنا تتطلب مستخدمًا مسجّل الدخول
public class TimetableController : ControllerBase
{
    private readonly TimetableService _timetableService;

    public TimetableController(TimetableService timetableService)
    {
        _timetableService = timetableService;
    }

    [HttpGet("weekly")]
    public async Task<ActionResult<List<TimetableEntryDto>>> GetWeekly()
        => Ok(await _timetableService.GetWeeklyAsync());

    [HttpGet("today")]
    public async Task<ActionResult<List<TimetableEntryDto>>> GetToday()
        => Ok(await _timetableService.GetTodayAsync());

    [HttpPost]
    public async Task<ActionResult<TimetableEntryDto>> Create([FromBody] CreateTimetableEntryRequest request)
    {
        var created = await _timetableService.CreateAsync(request);
        return CreatedAtAction(nameof(GetWeekly), new { }, created);
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        await _timetableService.DeleteAsync(id);
        return NoContent();
    }
}
