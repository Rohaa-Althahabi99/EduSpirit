using EduSpirit.Application.DTOs;
using EduSpirit.Application.Interfaces;

namespace EduSpirit.Application.Services;

public class DashboardService
{
    private readonly IUnitOfWork _uow;
    private readonly ICurrentUserService _currentUser;
    private readonly TimetableService _timetableService;
    private readonly ExamService _examService;
    private readonly AttendanceService _attendanceService;
    private readonly AssignmentService _assignmentService;

    public DashboardService(
        IUnitOfWork uow,
        ICurrentUserService currentUser,
        TimetableService timetableService,
        ExamService examService,
        AttendanceService attendanceService,
        AssignmentService assignmentService)
    {
        _uow = uow;
        _currentUser = currentUser;
        _timetableService = timetableService;
        _examService = examService;
        _attendanceService = attendanceService;
        _assignmentService = assignmentService;
    }

    public async Task<DashboardResponse> BuildAsync()
    {
        var user = await _uow.Users.GetByIdAsync(_currentUser.UserId);
        var todaySchedule = await _timetableService.GetTodayAsync();

        var nextExam = await _examService.GetNextExamAsync();
        var nextExamDto = nextExam == null ? null : new ExamCountdownDto(
            nextExam.Id, nextExam.CourseName, nextExam.ExamType, nextExam.ExamDate,
            nextExam.DaysRemaining, nextExam.HallLocation);

        var attendancePercentage = await _attendanceService.GetOverallPercentageAsync();
        var pendingTasksCount = await _assignmentService.GetPendingCountAsync();

        return new DashboardResponse(
            GreetingName: user?.FullName ?? "طالب",
            TodaySchedule: todaySchedule,
            NextExam: nextExamDto,
            AttendancePercentage: attendancePercentage,
            PendingTasksCount: pendingTasksCount
        );
    }
}
