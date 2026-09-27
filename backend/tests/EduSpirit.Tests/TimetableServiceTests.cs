using EduSpirit.Application.DTOs;
using EduSpirit.Application.Exceptions;
using EduSpirit.Application.Interfaces;
using EduSpirit.Application.Services;
using EduSpirit.Domain.Entities;
using FluentAssertions;
using Moq;
using Xunit;

namespace EduSpirit.Tests;

public class TimetableServiceTests
{
    private readonly Mock<IUnitOfWork> _uowMock = new();
    private readonly Mock<IGenericRepository<TimetableEntry>> _timetableRepoMock = new();
    private readonly Mock<ICurrentUserService> _currentUserMock = new();
    private readonly Guid _userId = Guid.NewGuid();

    public TimetableServiceTests()
    {
        _uowMock.SetupGet(u => u.TimetableEntries).Returns(_timetableRepoMock.Object);
        _uowMock.Setup(u => u.SaveChangesAsync()).ReturnsAsync(1);
        _currentUserMock.SetupGet(c => c.UserId).Returns(_userId);
    }

    private TimetableService CreateService() => new(_uowMock.Object, _currentUserMock.Object);

    [Fact]
    public async Task CreateAsync_WhenTimeOverlapsExistingLecture_ThrowsConflictException()
    {
        // Arrange: توجد محاضرة أخرى بنفس اليوم (الأحد=1) من 09:00 إلى 10:30
        var existingLecture = new TimetableEntry
        {
            UserId = _userId,
            Title = "هياكل بيانات",
            DayOfWeek = 1,
            StartTime = new TimeOnly(9, 0),
            EndTime = new TimeOnly(10, 30),
        };

        _timetableRepoMock
            .Setup(r => r.FirstOrDefaultAsync(It.IsAny<System.Linq.Expressions.Expression<Func<TimetableEntry, bool>>>()))
            .ReturnsAsync(existingLecture);

        var service = CreateService();

        // محاضرة جديدة تتقاطع زمنيًا: 10:00 - 11:00 بنفس اليوم
        var request = new CreateTimetableEntryRequest(
            "أنظمة تشغيل", null, "lecture", "قاعة 5", null, 1,
            new TimeOnly(10, 0), new TimeOnly(11, 0), DateOnly.FromDateTime(DateTime.Today), null, true, null);

        // Act
        var act = async () => await service.CreateAsync(request);

        // Assert: يجب رفض الإضافة بسبب التعارض الزمني
        await act.Should().ThrowAsync<ConflictException>();
    }

    [Fact]
    public async Task CreateAsync_WhenEndTimeBeforeStartTime_ThrowsAppException()
    {
        var service = CreateService();
        var request = new CreateTimetableEntryRequest(
            "محاضرة خاطئة", null, "lecture", null, null, 2,
            new TimeOnly(11, 0), new TimeOnly(10, 0), DateOnly.FromDateTime(DateTime.Today), null, true, null);

        var act = async () => await service.CreateAsync(request);

        await act.Should().ThrowAsync<AppException>();
    }
}
