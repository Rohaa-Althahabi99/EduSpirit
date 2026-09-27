using EduSpirit.Application.DTOs;
using EduSpirit.Application.Exceptions;
using EduSpirit.Application.Interfaces;
using EduSpirit.Domain.Entities;

namespace EduSpirit.Application.Services;

public class StudyService
{
    private readonly IUnitOfWork _uow;
    private readonly ICurrentUserService _currentUser;

    public StudyService(IUnitOfWork uow, ICurrentUserService currentUser)
    {
        _uow = uow;
        _currentUser = currentUser;
    }

    public async Task<Guid> StartSessionAsync(StartStudySessionRequest request)
    {
        var session = new StudySession
        {
            UserId = _currentUser.UserId,
            CourseId = request.CourseId,
            Mode = request.Mode,
            StartedAt = DateTime.UtcNow,
            DurationMinutes = 0,
        };
        await _uow.StudySessions.AddAsync(session);
        await _uow.SaveChangesAsync();
        return session.Id;
    }

    public async Task EndSessionAsync(EndStudySessionRequest request)
    {
        var session = await _uow.StudySessions.GetByIdAsync(request.SessionId)
                      ?? throw new NotFoundException("جلسة الدراسة");
        if (session.UserId != _currentUser.UserId) throw new ForbiddenAppException();

        session.EndedAt = DateTime.UtcNow;
        session.DurationMinutes = (int)(session.EndedAt.Value - session.StartedAt).TotalMinutes;
        _uow.StudySessions.Update(session);

        await UpdateStreakAsync();
        await _uow.SaveChangesAsync();
    }

    public async Task<StudyStreakDto> GetStreakAsync()
    {
        var streak = await _uow.StudyStreaks.GetByIdAsync(_currentUser.UserId);
        if (streak == null) return new StudyStreakDto(0, 0, null);
        return new StudyStreakDto(streak.CurrentStreak, streak.LongestStreak, streak.LastStudyDate);
    }

    public async Task<int> GetTotalMinutesThisWeekAsync()
    {
        var weekStart = DateTime.UtcNow.Date.AddDays(-(int)DateTime.UtcNow.DayOfWeek);
        var sessions = await _uow.StudySessions.FindAsync(s =>
            s.UserId == _currentUser.UserId && s.StartedAt >= weekStart && s.EndedAt != null);
        return sessions.Sum(s => s.DurationMinutes);
    }

    private async Task UpdateStreakAsync()
    {
        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        var streak = await _uow.StudyStreaks.GetByIdAsync(_currentUser.UserId);

        if (streak == null)
        {
            streak = new StudyStreak { UserId = _currentUser.UserId, CurrentStreak = 1, LongestStreak = 1, LastStudyDate = today };
            await _uow.StudyStreaks.AddAsync(streak);
            return;
        }

        if (streak.LastStudyDate == today) return; // مسجَّل بالفعل اليوم

        streak.CurrentStreak = (streak.LastStudyDate == today.AddDays(-1)) ? streak.CurrentStreak + 1 : 1;
        streak.LongestStreak = Math.Max(streak.LongestStreak, streak.CurrentStreak);
        streak.LastStudyDate = today;
        _uow.StudyStreaks.Update(streak);
    }
}
