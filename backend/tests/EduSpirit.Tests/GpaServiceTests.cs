using EduSpirit.Application.Interfaces;
using EduSpirit.Application.Services;
using EduSpirit.Domain.Entities;
using FluentAssertions;
using Moq;
using Xunit;

namespace EduSpirit.Tests;

public class GpaServiceTests
{
    private readonly Mock<IUnitOfWork> _uowMock = new();
    private readonly Mock<IGenericRepository<CourseGrade>> _gradesRepoMock = new();
    private readonly Mock<ICurrentUserService> _currentUserMock = new();
    private readonly Guid _userId = Guid.NewGuid();

    public GpaServiceTests()
    {
        _uowMock.SetupGet(u => u.CourseGrades).Returns(_gradesRepoMock.Object);
        _currentUserMock.SetupGet(c => c.UserId).Returns(_userId);
    }

    [Fact]
    public async Task CalculateAsync_ComputesWeightedGpaByCreditHours()
    {
        // Arrange: مادتان بنفس الفصل — A (4.0 نقطة × 3 ساعات) و B (3.0 نقطة × 4 ساعات)
        // GPA المتوقع = (4.0*3 + 3.0*4) / (3+4) = 24/7 = 3.43
        var grades = new List<CourseGrade>
        {
            new() { UserId = _userId, Semester = "Fall2026", GradePoints = 4.0m, CreditHours = 3 },
            new() { UserId = _userId, Semester = "Fall2026", GradePoints = 3.0m, CreditHours = 4 },
        };

        _gradesRepoMock
            .Setup(r => r.FindAsync(It.IsAny<System.Linq.Expressions.Expression<Func<CourseGrade, bool>>>()))
            .ReturnsAsync(grades);

        var service = new GpaService(_uowMock.Object, _currentUserMock.Object);

        // Act
        var result = await service.CalculateAsync();

        // Assert
        result.OverallGpa.Should().Be(3.43m);
        result.TotalCreditHours.Should().Be(7);
        result.BySemester.Should().ContainSingle(s => s.Semester == "Fall2026");
    }

    [Fact]
    public async Task CalculateAsync_WhenNoGrades_ReturnsZeroWithoutThrowing()
    {
        _gradesRepoMock
            .Setup(r => r.FindAsync(It.IsAny<System.Linq.Expressions.Expression<Func<CourseGrade, bool>>>()))
            .ReturnsAsync(new List<CourseGrade>());

        var service = new GpaService(_uowMock.Object, _currentUserMock.Object);

        var result = await service.CalculateAsync();

        result.OverallGpa.Should().Be(0);
        result.TotalCreditHours.Should().Be(0);
    }
}
