using EduSpirit.Application.DTOs;
using EduSpirit.Application.Exceptions;
using EduSpirit.Application.Interfaces;
using EduSpirit.Application.Services;
using EduSpirit.Domain.Entities;
using FluentAssertions;
using Moq;
using Xunit;

namespace EduSpirit.Tests;

public class AuthServiceTests
{
    private readonly Mock<IEmailService> _emailMock = new();
    private readonly Mock<IGoogleTokenValidator> _googleMock = new();
    private readonly Mock<IUnitOfWork> _uowMock = new();
    private readonly Mock<IGenericRepository<User>> _usersRepoMock = new();
    private readonly Mock<IGenericRepository<RefreshToken>> _refreshRepoMock = new();
    private readonly Mock<IPasswordHasher> _hasherMock = new();
    private readonly Mock<IJwtTokenService> _jwtMock = new();

    public AuthServiceTests()
    {
        _uowMock.SetupGet(u => u.Users).Returns(_usersRepoMock.Object);
        _uowMock.SetupGet(u => u.RefreshTokens).Returns(_refreshRepoMock.Object);
        _uowMock.Setup(u => u.SaveChangesAsync()).ReturnsAsync(1);
    }

    private AuthService CreateService() => new(_uowMock.Object, _hasherMock.Object, _jwtMock.Object, _emailMock.Object, _googleMock.Object);
    [Fact]
    public async Task RegisterAsync_WhenEmailAlreadyExists_ThrowsConflictException()
    {
        // Arrange: يوجد مستخدم بنفس البريد بالفعل
        _usersRepoMock
            .Setup(r => r.FirstOrDefaultAsync(It.IsAny<System.Linq.Expressions.Expression<Func<User, bool>>>()))
            .ReturnsAsync(new User { Email = "test@eduspirit.app" });

        var service = CreateService();
        var request = new RegisterRequest("طالب تجريبي", "test@eduspirit.app", "Password123");

        // Act
        var act = async () => await service.RegisterAsync(request);

        // Assert: يجب أن يرفض التسجيل بخطأ 409 وليس بإنشاء حساب مكرر
        await act.Should().ThrowAsync<ConflictException>();
    }

    [Fact]
    public async Task LoginAsync_WhenPasswordIncorrect_ThrowsUnauthorizedException_WithGenericMessage()
    {
        // Arrange
        var existingUser = new User { Email = "student@eduspirit.app", PasswordHash = "hashed" };
        _usersRepoMock
            .Setup(r => r.FirstOrDefaultAsync(It.IsAny<System.Linq.Expressions.Expression<Func<User, bool>>>()))
            .ReturnsAsync(existingUser);
        _hasherMock.Setup(h => h.Verify(It.IsAny<string>(), It.IsAny<string>())).Returns(false);

        var service = CreateService();
        var request = new LoginRequest("student@eduspirit.app", "WrongPassword");

        // Act
        var act = async () => await service.LoginAsync(request);

        // Assert: رسالة الخطأ يجب ألّا تكشف هل البريد صحيح أو كلمة المرور فقط (User Enumeration)
        var exception = await act.Should().ThrowAsync<UnauthorizedAppException>();
        exception.Which.Message.Should().Be("البريد الإلكتروني أو كلمة المرور غير صحيحة.");
    }

    [Fact]
    public async Task LoginAsync_WhenCredentialsValid_ReturnsTokens()
    {
        // Arrange
        var existingUser = new User { Id = Guid.NewGuid(), FullName = "أحمد", Email = "a@eduspirit.app", PasswordHash = "hashed" };
        _usersRepoMock
            .Setup(r => r.FirstOrDefaultAsync(It.IsAny<System.Linq.Expressions.Expression<Func<User, bool>>>()))
            .ReturnsAsync(existingUser);
        _hasherMock.Setup(h => h.Verify(It.IsAny<string>(), "hashed")).Returns(true);
        _jwtMock.Setup(j => j.GenerateTokens(existingUser))
            .Returns(new TokenPair("access-token", "refresh-token", DateTime.UtcNow.AddMinutes(15)));
        _jwtMock.Setup(j => j.HashToken(It.IsAny<string>())).Returns("hashed-refresh");

        var service = CreateService();

        // Act
        var result = await service.LoginAsync(new LoginRequest("a@eduspirit.app", "CorrectPassword"));

        // Assert
        result.AccessToken.Should().Be("access-token");
        result.User.FullName.Should().Be("أحمد");
    }
}
