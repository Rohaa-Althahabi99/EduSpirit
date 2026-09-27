namespace EduSpirit.Application.DTOs;

public record StartStudySessionRequest(string Mode, Guid? CourseId);
public record EndStudySessionRequest(Guid SessionId);

public record StudySessionDto(Guid Id, string Mode, int DurationMinutes, DateTime StartedAt, DateTime? EndedAt);

public record StudyStreakDto(int CurrentStreak, int LongestStreak, DateOnly? LastStudyDate);
