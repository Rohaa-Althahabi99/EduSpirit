using EduSpirit.Application.DTOs;
using EduSpirit.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EduSpirit.API.Controllers;

[ApiController]
[Route("api/v1/projects")]
[Authorize]
public class ProjectsController : ControllerBase
{
    private readonly ProjectService _projectService;
    public ProjectsController(ProjectService projectService) => _projectService = projectService;

    [HttpGet]
    public async Task<ActionResult<List<ProjectDto>>> GetMine() => Ok(await _projectService.GetMyProjectsAsync());

    [HttpPost]
    public async Task<ActionResult<ProjectDto>> Create([FromBody] CreateProjectRequest request)
        => Ok(await _projectService.CreateAsync(request));

    [HttpPost("{id:guid}/members")]
    public async Task<IActionResult> AddMember(Guid id, [FromBody] AddProjectMemberRequest request)
    {
        await _projectService.AddMemberAsync(id, request);
        return NoContent();
    }

    [HttpPost("{id:guid}/tasks")]
    public async Task<IActionResult> AddTask(Guid id, [FromBody] AddProjectTaskRequest request)
    {
        await _projectService.AddTaskAsync(id, request);
        return NoContent();
    }

    [HttpPatch("tasks/{taskId:guid}")]
    public async Task<IActionResult> ToggleTask(Guid taskId, [FromQuery] bool isDone)
    {
        await _projectService.ToggleTaskAsync(taskId, isDone);
        return NoContent();
    }

    [HttpPost("{id:guid}/milestones")]
    public async Task<IActionResult> AddMilestone(Guid id, [FromBody] AddProjectMilestoneRequest request)
    {
        await _projectService.AddMilestoneAsync(id, request);
        return NoContent();
    }

    [HttpPatch("{id:guid}/progress")]
    public async Task<IActionResult> UpdateProgress(Guid id, [FromBody] UpdateProjectProgressRequest request)
    {
        await _projectService.UpdateProgressAsync(id, request);
        return NoContent();
    }
}
