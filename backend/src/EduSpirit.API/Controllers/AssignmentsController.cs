using EduSpirit.Application.DTOs;
using EduSpirit.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EduSpirit.API.Controllers;

[ApiController]
[Route("api/v1/assignments")]
[Authorize]
public class AssignmentsController : ControllerBase
{
    private readonly AssignmentService _assignmentService;
    public AssignmentsController(AssignmentService assignmentService) => _assignmentService = assignmentService;

    [HttpGet]
    public async Task<ActionResult<List<AssignmentDto>>> GetAll() => Ok(await _assignmentService.GetAllAsync());

    [HttpPost]
    public async Task<ActionResult<AssignmentDto>> Create([FromBody] CreateAssignmentRequest request)
        => Ok(await _assignmentService.CreateAsync(request));

    [HttpPatch("{id:guid}/progress")]
    public async Task<ActionResult<AssignmentDto>> UpdateProgress(Guid id, [FromBody] UpdateAssignmentProgressRequest request)
        => Ok(await _assignmentService.UpdateProgressAsync(id, request));

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        await _assignmentService.DeleteAsync(id);
        return NoContent();
    }
}
