using EduSpirit.Application.DTOs;
using EduSpirit.Application.Interfaces;
using EduSpirit.Domain.Entities;

namespace EduSpirit.Application.Services;

public class GpaService
{
    private readonly IUnitOfWork _uow;
    private readonly ICurrentUserService _currentUser;

    public GpaService(IUnitOfWork uow, ICurrentUserService currentUser)
    {
        _uow = uow;
        _currentUser = currentUser;
    }

    public async Task AddGradeAsync(AddGradeRequest request)
    {
        var grade = new CourseGrade
        {
            UserId = _currentUser.UserId,
            CourseId = request.CourseId,
            Semester = request.Semester,
            LetterGrade = request.LetterGrade,
            GradePoints = request.GradePoints,
            CreditHours = request.CreditHours,
        };
        await _uow.CourseGrades.AddAsync(grade);
        await _uow.SaveChangesAsync();
    }

    public async Task<GpaResponse> CalculateAsync()
    {
        var grades = await _uow.CourseGrades.FindAsync(g => g.UserId == _currentUser.UserId);

        var bySemester = grades
            .GroupBy(g => g.Semester)
            .Select(group =>
            {
                var totalCredits = group.Sum(g => g.CreditHours);
                var weightedPoints = group.Sum(g => (g.GradePoints ?? 0) * g.CreditHours);
                var gpa = totalCredits == 0 ? 0 : Math.Round(weightedPoints / totalCredits, 2);
                return new SemesterGpaDto(group.Key, gpa, totalCredits);
            })
            .ToList();

        var overallCredits = grades.Sum(g => g.CreditHours);
        var overallWeighted = grades.Sum(g => (g.GradePoints ?? 0) * g.CreditHours);
        var overallGpa = overallCredits == 0 ? 0 : Math.Round(overallWeighted / overallCredits, 2);

        var currentSemesterGpa = bySemester.LastOrDefault()?.Gpa ?? 0;

        return new GpaResponse(currentSemesterGpa, overallGpa, overallCredits, bySemester);
    }
}
