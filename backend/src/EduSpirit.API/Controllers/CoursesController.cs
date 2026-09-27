using EduSpirit.Application.DTOs;
using EduSpirit.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EduSpirit.API.Controllers;

[ApiController]
[Route("api/v1/courses")]
[Authorize]
public class CoursesController : ControllerBase
{
    private readonly CourseService _courseService;
    public CoursesController(CourseService courseService) => _courseService = courseService;

    [HttpGet]
    public async Task<ActionResult<List<CourseDto>>> GetAll() => Ok(await _courseService.GetAllAsync());

    [HttpPost]
    public async Task<ActionResult<CourseDto>> Create([FromBody] CreateCourseRequest request)
        => Ok(await _courseService.CreateAsync(request));

    [HttpPut("{id:guid}")]
    public async Task<ActionResult<CourseDto>> Update(Guid id, [FromBody] UpdateCourseRequest request)
        => Ok(await _courseService.UpdateAsync(id, request));

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        await _courseService.DeleteAsync(id);
        return NoContent();
    }
}
