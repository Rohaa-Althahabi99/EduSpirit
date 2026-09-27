using EduSpirit.Application.DTOs;
using EduSpirit.Application.Exceptions;
using EduSpirit.Application.Interfaces;
using EduSpirit.Domain.Entities;

namespace EduSpirit.Application.Services;

public class ProjectService
{
    private readonly IUnitOfWork _uow;
    private readonly ICurrentUserService _currentUser;

    public ProjectService(IUnitOfWork uow, ICurrentUserService currentUser)
    {
        _uow = uow;
        _currentUser = currentUser;
    }

    public async Task<ProjectDto> CreateAsync(CreateProjectRequest request)
    {
        var project = new Project
        {
            OwnerUserId = _currentUser.UserId,
            CourseId = request.CourseId,
            Title = request.Title.Trim(),
            Description = request.Description,
            DueDate = request.DueDate,
        };
        await _uow.Projects.AddAsync(project);

        // المالك يُضاف تلقائيًا كعضو بدور "owner" حتى تظهر مهامه في قوائمه الشخصية.
        await _uow.ProjectMembers.AddAsync(new ProjectMember
        {
            ProjectId = project.Id,
            UserId = _currentUser.UserId,
            RoleInProject = "owner",
        });

        await _uow.SaveChangesAsync();
        return await BuildDtoAsync(project);
    }

    public async Task<List<ProjectDto>> GetMyProjectsAsync()
    {
        var memberships = await _uow.ProjectMembers.FindAsync(m => m.UserId == _currentUser.UserId);
        var projectIds = memberships.Select(m => m.ProjectId).ToHashSet();

        var projects = await _uow.Projects.FindAsync(p => projectIds.Contains(p.Id) && !p.IsDeleted);
        var result = new List<ProjectDto>();
        foreach (var p in projects) result.Add(await BuildDtoAsync(p));
        return result;
    }

    public async Task AddTaskAsync(Guid projectId, AddProjectTaskRequest request)
    {
        await EnsureMemberAsync(projectId);
        await _uow.ProjectTasks.AddAsync(new ProjectTask { ProjectId = projectId, Title = request.Title.Trim(), DueDate = request.DueDate });
        await _uow.SaveChangesAsync();
    }

    public async Task ToggleTaskAsync(Guid taskId, bool isDone)
    {
        var task = await _uow.ProjectTasks.GetByIdAsync(taskId) ?? throw new NotFoundException("مهمة المشروع");
        await EnsureMemberAsync(task.ProjectId);
        task.IsDone = isDone;
        _uow.ProjectTasks.Update(task);
        await _uow.SaveChangesAsync();
    }

    public async Task AddMilestoneAsync(Guid projectId, AddProjectMilestoneRequest request)
    {
        await EnsureMemberAsync(projectId);
        await _uow.ProjectMilestones.AddAsync(new ProjectMilestone { ProjectId = projectId, Title = request.Title.Trim(), DueDate = request.DueDate });
        await _uow.SaveChangesAsync();
    }

    public async Task UpdateProgressAsync(Guid projectId, UpdateProjectProgressRequest request)
    {
        var project = await _uow.Projects.GetByIdAsync(projectId) ?? throw new NotFoundException("المشروع");
        await EnsureMemberAsync(projectId);
        project.ProgressPercent = Math.Clamp(request.ProgressPercent, (byte)0, (byte)100);
        _uow.Projects.Update(project);
        await _uow.SaveChangesAsync();
    }

    public async Task AddMemberAsync(Guid projectId, AddProjectMemberRequest request)
    {
        var project = await _uow.Projects.GetByIdAsync(projectId) ?? throw new NotFoundException("المشروع");
        if (project.OwnerUserId != _currentUser.UserId)
            throw new ForbiddenAppException("فقط منشئ المشروع يمكنه إضافة أعضاء.");

        var invitedUser = await _uow.Users.FirstOrDefaultAsync(u => u.Email == request.MemberEmail.Trim().ToLower())
                          ?? throw new NotFoundException("مستخدم بهذا البريد الإلكتروني");

        var alreadyMember = await _uow.ProjectMembers.FirstOrDefaultAsync(m => m.ProjectId == projectId && m.UserId == invitedUser.Id);
        if (alreadyMember != null) throw new ConflictException("هذا الطالب عضو بالفريق بالفعل.");

        await _uow.ProjectMembers.AddAsync(new ProjectMember { ProjectId = projectId, UserId = invitedUser.Id, RoleInProject = "member" });
        await _uow.SaveChangesAsync();
    }

    private async Task EnsureMemberAsync(Guid projectId)
    {
        var membership = await _uow.ProjectMembers.FirstOrDefaultAsync(m => m.ProjectId == projectId && m.UserId == _currentUser.UserId);
        if (membership == null) throw new ForbiddenAppException("لست عضوًا بهذا المشروع.");
    }

    private async Task<ProjectDto> BuildDtoAsync(Project project)
    {
        var course = project.CourseId != null ? await _uow.Courses.GetByIdAsync(project.CourseId.Value) : null;

        var members = await _uow.ProjectMembers.FindAsync(m => m.ProjectId == project.Id);
        var memberDtos = new List<ProjectMemberDto>();
        foreach (var m in members)
        {
            var user = await _uow.Users.GetByIdAsync(m.UserId);
            memberDtos.Add(new ProjectMemberDto(m.UserId, user?.FullName ?? "", m.RoleInProject));
        }

        var tasks = await _uow.ProjectTasks.FindAsync(t => t.ProjectId == project.Id);
        var milestones = await _uow.ProjectMilestones.FindAsync(m => m.ProjectId == project.Id);

        return new ProjectDto(
            project.Id, project.Title, course?.Name, project.Description, project.DueDate, project.ProgressPercent,
            memberDtos,
            tasks.Select(t => new ProjectTaskDto(t.Id, t.Title, t.IsDone, t.DueDate)).ToList(),
            milestones.Select(m => new ProjectMilestoneDto(m.Id, m.Title, m.IsDone, m.DueDate)).ToList());
    }
}
