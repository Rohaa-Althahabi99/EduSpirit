using EduSpirit.Application.DTOs;
using EduSpirit.Application.Exceptions;
using EduSpirit.Application.Interfaces;
using EduSpirit.Domain.Entities;

namespace EduSpirit.Application.Services;

public class AttendanceService
{
    private readonly IUnitOfWork _uow;
    private readonly ICurrentUserService _currentUser;

    public AttendanceService(IUnitOfWork uow, ICurrentUserService currentUser)
    {
        _uow = uow;
        _currentUser = currentUser;
    }

    public async Task MarkAsync(MarkAttendanceRequest request)
    {
        var course = await _uow.Courses.GetByIdAsync(request.CourseId) ?? throw new NotFoundException("المادة");
        if (course.UserId != _currentUser.UserId) throw new ForbiddenAppException();

        // upsert: لو موجود سجل لنفس اليوم/المادة نعدّله بدل تكراره (الـ Unique Index في القاعدة يحميه أصلًا)
        var existing = await _uow.AttendanceRecords.FirstOrDefaultAsync(r =>
            r.UserId == _currentUser.UserId && r.CourseId == request.CourseId && r.SessionDate == request.SessionDate);

        if (existing != null)
        {
            existing.Status = request.Status;
            _uow.AttendanceRecords.Update(existing);
        }
        else
        {
            await _uow.AttendanceRecords.AddAsync(new AttendanceRecord
            {
                UserId = _currentUser.UserId,
                CourseId = request.CourseId,
                SessionDate = request.SessionDate,
                Status = request.Status,
            });
        }
        await _uow.SaveChangesAsync();
    }

    public async Task<List<CourseAttendanceStatsDto>> GetStatsAsync()
    {
        var courses = await _uow.Courses.FindAsync(c => c.UserId == _currentUser.UserId && !c.IsDeleted);
        var result = new List<CourseAttendanceStatsDto>();

        foreach (var course in courses)
        {
            var records = await _uow.AttendanceRecords.FindAsync(r => r.CourseId == course.Id);
            var total = records.Count;
            var present = records.Count(r => r.Status == "present");
            var absent = records.Count(r => r.Status == "absent");
            var late = records.Count(r => r.Status == "late");
            var percentage = total == 0 ? 100.0 : Math.Round((present + late * 0.5) / total * 100, 1);

            result.Add(new CourseAttendanceStatsDto(course.Id, course.Name, total, present, absent, late, percentage));
        }
        return result;
    }

    public async Task<double> GetOverallPercentageAsync()
    {
        var stats = await GetStatsAsync();
        if (stats.Count == 0) return 100.0;
        return Math.Round(stats.Average(s => s.AttendancePercentage), 1);
    }
}
