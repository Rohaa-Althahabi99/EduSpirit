using EduSpirit.Application.DTOs;
using EduSpirit.Application.Exceptions;
using EduSpirit.Application.Interfaces;
using EduSpirit.Domain.Entities;

namespace EduSpirit.Application.Services;

public class ExamService
{
    private readonly IUnitOfWork _uow;
    private readonly ICurrentUserService _currentUser;

    public ExamService(IUnitOfWork uow, ICurrentUserService currentUser)
    {
        _uow = uow;
        _currentUser = currentUser;
    }

    public async Task<ExamDto> CreateAsync(CreateExamRequest request)
    {
        var course = await _uow.Courses.GetByIdAsync(request.CourseId)
                     ?? throw new NotFoundException("المادة الدراسية");

        if (course.UserId != _currentUser.UserId) throw new ForbiddenAppException();

        var exam = new Exam
        {
            UserId = _currentUser.UserId,
            CourseId = request.CourseId,
            ExamType = request.ExamType,
            ExamDate = request.ExamDate,
            HallLocation = request.HallLocation,
            Instructions = request.Instructions,
            IncludedChapters = request.IncludedChapters,
            ExcludedChapters = request.ExcludedChapters,
            ImportantTopics = request.ImportantTopics,
            ProfessorNotes = request.ProfessorNotes,
            Difficulty = request.Difficulty,
            Priority = request.Priority,
        };

        await _uow.Exams.AddAsync(exam);
        await _uow.SaveChangesAsync();

        return ToDto(exam, course.Name);
    }

    public async Task<List<ExamDto>> GetUpcomingAsync()
    {
        var exams = await _uow.Exams.FindAsync(e =>
            e.UserId == _currentUser.UserId && !e.IsDeleted && e.ExamDate >= DateTime.UtcNow);

        var result = new List<ExamDto>();
        foreach (var exam in exams.OrderBy(e => e.ExamDate))
        {
            var course = await _uow.Courses.GetByIdAsync(exam.CourseId);
            result.Add(ToDto(exam, course?.Name ?? ""));
        }
        return result;
    }

    public async Task<ExamDto?> GetNextExamAsync()
    {
        var exams = await GetUpcomingAsync();
        return exams.FirstOrDefault();
    }

    public async Task<ExamChecklistItemDto> AddChecklistItemAsync(Guid examId, AddChecklistItemRequest request)
    {
        var exam = await _uow.Exams.GetByIdAsync(examId) ?? throw new NotFoundException("الامتحان");
        if (exam.UserId != _currentUser.UserId) throw new ForbiddenAppException();

        var item = new ExamChecklistItem { ExamId = examId, Content = request.Content.Trim() };
        await _uow.ExamChecklistItems.AddAsync(item);
        await _uow.SaveChangesAsync();

        return new ExamChecklistItemDto(item.Id, item.Content, item.IsDone);
    }

    public async Task ToggleChecklistItemAsync(Guid itemId, bool isDone)
    {
        var item = await _uow.ExamChecklistItems.GetByIdAsync(itemId)
                   ?? throw new NotFoundException("عنصر قائمة التحضير");

        var exam = await _uow.Exams.GetByIdAsync(item.ExamId) ?? throw new NotFoundException("الامتحان");
        if (exam.UserId != _currentUser.UserId) throw new ForbiddenAppException();

        item.IsDone = isDone;
        _uow.ExamChecklistItems.Update(item);
        await _uow.SaveChangesAsync();
    }

    private static ExamDto ToDto(Exam e, string courseName) => new(
        e.Id, courseName, e.ExamType, e.ExamDate,
        (int)Math.Ceiling((e.ExamDate.Date - DateTime.UtcNow.Date).TotalDays),
        e.HallLocation, e.Instructions, e.IncludedChapters, e.ExcludedChapters,
        e.ImportantTopics, e.ProfessorNotes, e.Difficulty, e.Priority,
        e.ChecklistItems?.Select(c => new ExamChecklistItemDto(c.Id, c.Content, c.IsDone)).ToList()
            ?? new List<ExamChecklistItemDto>());
}
