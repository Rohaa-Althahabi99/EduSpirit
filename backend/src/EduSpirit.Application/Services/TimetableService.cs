using EduSpirit.Application.DTOs;
using EduSpirit.Application.Exceptions;
using EduSpirit.Application.Interfaces;
using EduSpirit.Domain.Entities;
using EduSpirit.Domain.Enums;

namespace EduSpirit.Application.Services;

public class TimetableService
{
    private readonly IUnitOfWork _uow;
    private readonly ICurrentUserService _currentUser;

    public TimetableService(IUnitOfWork uow, ICurrentUserService currentUser)
    {
        _uow = uow;
        _currentUser = currentUser;
    }

    public async Task<TimetableEntryDto> CreateAsync(CreateTimetableEntryRequest request)
    {
        if (request.EndTime <= request.StartTime)
            throw new AppException("وقت النهاية يجب أن يكون بعد وقت البداية.");

        // كشف التعارض: هل يوجد فعليًا حصة أخرى لنفس المستخدم بنفس اليوم تتقاطع بالوقت؟
        var conflict = await _uow.TimetableEntries.FirstOrDefaultAsync(t =>
            t.UserId == _currentUser.UserId &&
            !t.IsDeleted &&
            t.DayOfWeek == request.DayOfWeek &&
            t.StartTime < request.EndTime &&
            request.StartTime < t.EndTime);

        if (conflict != null)
            throw new ConflictException($"يوجد تعارض مع محاضرة أخرى: {conflict.Title}");

        var entry = new TimetableEntry
        {
            UserId = _currentUser.UserId,
            CourseId = request.CourseId,
            Title = request.Title.Trim(),
            EntryType = Enum.Parse<TimetableEntryType>(request.EntryType, ignoreCase: true),
            Location = request.Location,
            OnlineLink = request.OnlineLink,
            DayOfWeek = request.DayOfWeek,
            StartTime = request.StartTime,
            EndTime = request.EndTime,
            StartDate = request.StartDate,
            EndDate = request.EndDate,
            IsRecurring = request.IsRecurring,
            ColorHex = request.ColorHex ?? "#2F6FED",
        };

        await _uow.TimetableEntries.AddAsync(entry);
        await _uow.SaveChangesAsync();

        return ToDto(entry, courseName: null);
    }

    public async Task<List<TimetableEntryDto>> GetWeeklyAsync()
    {
        var entries = await _uow.TimetableEntries.FindAsync(t =>
            t.UserId == _currentUser.UserId && !t.IsDeleted);

        return entries
            .OrderBy(e => e.DayOfWeek).ThenBy(e => e.StartTime)
            .Select(e => ToDto(e, e.Course?.Name))
            .ToList();
    }

    public async Task<List<TimetableEntryDto>> GetTodayAsync()
    {
        var todayDayOfWeek = (byte)((int)DateTime.Now.DayOfWeek + 1); // 1=Sunday..7=Saturday
        var entries = await _uow.TimetableEntries.FindAsync(t =>
            t.UserId == _currentUser.UserId && !t.IsDeleted && t.DayOfWeek == todayDayOfWeek);

        return entries.OrderBy(e => e.StartTime).Select(e => ToDto(e, e.Course?.Name)).ToList();
    }

    public async Task DeleteAsync(Guid entryId)
    {
        var entry = await _uow.TimetableEntries.GetByIdAsync(entryId)
                     ?? throw new NotFoundException("الحصة الدراسية");

        // فحص الملكية: لا يمكن لأي مستخدم حذف حصة مستخدم آخر حتى لو خمّن الـ Id.
        if (entry.UserId != _currentUser.UserId)
            throw new ForbiddenAppException();

        entry.IsDeleted = true;
        _uow.TimetableEntries.Update(entry);
        await _uow.SaveChangesAsync();
    }

    private static TimetableEntryDto ToDto(TimetableEntry e, string? courseName) => new(
        e.Id, e.Title, e.EntryType.ToString().ToLower(), courseName,
        e.Location, e.OnlineLink, e.DayOfWeek, e.StartTime, e.EndTime,
        e.ColorHex ?? "#2F6FED");
}
