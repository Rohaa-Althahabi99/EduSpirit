using EduSpirit.Application.DTOs;
using EduSpirit.Application.Exceptions;
using EduSpirit.Application.Interfaces;
using EduSpirit.Domain.Entities;

namespace EduSpirit.Application.Services;

public class AssignmentService
{
    private readonly IUnitOfWork _uow;
    private readonly ICurrentUserService _currentUser;

    public AssignmentService(IUnitOfWork uow, ICurrentUserService currentUser)
    {
        _uow = uow;
        _currentUser = currentUser;
    }

    public async Task<AssignmentDto> CreateAsync(CreateAssignmentRequest request)
    {
        var assignment = new Assignment
        {
            UserId = _currentUser.UserId,
            Title = request.Title.Trim(),
            CourseId = request.CourseId,
            AssignmentType = request.AssignmentType,
            Description = request.Description,
            DueDate = request.DueDate,
            Priority = request.Priority,
        };

        await _uow.Assignments.AddAsync(assignment);
        await _uow.SaveChangesAsync();

        var courseName = request.CourseId != null
            ? (await _uow.Courses.GetByIdAsync(request.CourseId.Value))?.Name
            : null;

        return ToDto(assignment, courseName);
    }

    public async Task<List<AssignmentDto>> GetAllAsync()
    {
        var assignments = await _uow.Assignments.FindAsync(a => a.UserId == _currentUser.UserId && !a.IsDeleted);
        var result = new List<AssignmentDto>();
        foreach (var a in assignments.OrderBy(a => a.DueDate))
        {
            var courseName = a.CourseId != null ? (await _uow.Courses.GetByIdAsync(a.CourseId.Value))?.Name : null;
            result.Add(ToDto(a, courseName));
        }
        return result;
    }

    public async Task<int> GetPendingCountAsync()
    {
        var assignments = await _uow.Assignments.FindAsync(a =>
            a.UserId == _currentUser.UserId && !a.IsDeleted && a.Status != "graded" && a.Status != "submitted");
        return assignments.Count;
    }

    public async Task<AssignmentDto> UpdateProgressAsync(Guid id, UpdateAssignmentProgressRequest request)
    {
        var assignment = await _uow.Assignments.GetByIdAsync(id) ?? throw new NotFoundException("الواجب");
        if (assignment.UserId != _currentUser.UserId) throw new ForbiddenAppException();

        assignment.ProgressPercent = Math.Clamp(request.ProgressPercent, (byte)0, (byte)100);
        assignment.Status = request.Status;
        _uow.Assignments.Update(assignment);
        await _uow.SaveChangesAsync();

        var courseName = assignment.CourseId != null
            ? (await _uow.Courses.GetByIdAsync(assignment.CourseId.Value))?.Name : null;
        return ToDto(assignment, courseName);
    }

    public async Task DeleteAsync(Guid id)
    {
        var assignment = await _uow.Assignments.GetByIdAsync(id) ?? throw new NotFoundException("الواجب");
        if (assignment.UserId != _currentUser.UserId) throw new ForbiddenAppException();

        assignment.IsDeleted = true;
        _uow.Assignments.Update(assignment);
        await _uow.SaveChangesAsync();
    }

    private static AssignmentDto ToDto(Assignment a, string? courseName) => new(
        a.Id, a.Title, courseName, a.AssignmentType, a.Description,
        a.DueDate, a.Priority, a.ProgressPercent, a.Status);
}
