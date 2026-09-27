using EduSpirit.Application.DTOs;
using EduSpirit.Application.Interfaces;

namespace EduSpirit.Application.Services;

public class StatisticsService
{
    private readonly IUnitOfWork _uow;
    private readonly ICurrentUserService _currentUser;
    private readonly AttendanceService _attendanceService;
    private readonly StudyService _studyService;

    public StatisticsService(
        IUnitOfWork uow,
        ICurrentUserService currentUser,
        AttendanceService attendanceService,
        StudyService studyService)
    {
        _uow = uow;
        _currentUser = currentUser;
        _attendanceService = attendanceService;
        _studyService = studyService;
    }

    public async Task<StatisticsResponse> BuildAsync()
    {
        var attendanceByCourse = await _attendanceService.GetStatsAsync();
        var overallAttendance = attendanceByCourse.Count == 0 ? 100.0
            : Math.Round(attendanceByCourse.Average(a => a.AttendancePercentage), 1);

        var totalStudyMinutes = await _studyService.GetTotalMinutesThisWeekAsync();

        var assignments = await _uow.Assignments.FindAsync(a => a.UserId == _currentUser.UserId && !a.IsDeleted);
        var completed = assignments.Count(a => a.Status is "submitted" or "graded");
        var pending = assignments.Count - completed;

        return new StatisticsResponse(
            totalStudyMinutes, completed, pending, overallAttendance, attendanceByCourse);
    }
}
