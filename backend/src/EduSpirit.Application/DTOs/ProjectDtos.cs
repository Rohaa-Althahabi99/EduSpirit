namespace EduSpirit.Application.DTOs;

public record CreateProjectRequest(string Title, Guid? CourseId, string? Description, DateTime? DueDate);
public record AddProjectTaskRequest(string Title, DateTime? DueDate);
public record AddProjectMilestoneRequest(string Title, DateTime? DueDate);
public record AddProjectMemberRequest(string MemberEmail);
public record AddProjectCommentRequest(string Content);
public record UpdateProjectProgressRequest(byte ProgressPercent);

public record ProjectTaskDto(Guid Id, string Title, bool IsDone, DateTime? DueDate);
public record ProjectMilestoneDto(Guid Id, string Title, bool IsDone, DateTime? DueDate);
public record ProjectMemberDto(Guid UserId, string FullName, string RoleInProject);

public record ProjectDto(
    Guid Id, string Title, string? CourseName, string? Description,
    DateTime? DueDate, byte ProgressPercent,
    List<ProjectMemberDto> Members, List<ProjectTaskDto> Tasks, List<ProjectMilestoneDto> Milestones
);
