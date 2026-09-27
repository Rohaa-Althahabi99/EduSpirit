using EduSpirit.Application.Interfaces;

namespace EduSpirit.Application.Services;

public record NotificationDto(Guid Id, string Title, string? Body, string NotificationType, bool IsRead, DateTime CreatedAt);

public class NotificationService
{
    private readonly IUnitOfWork _uow;
    private readonly ICurrentUserService _currentUser;

    public NotificationService(IUnitOfWork uow, ICurrentUserService currentUser)
    {
        _uow = uow;
        _currentUser = currentUser;
    }

    public async Task<List<NotificationDto>> GetAllAsync()
    {
        var notifications = await _uow.Notifications.FindAsync(n => n.UserId == _currentUser.UserId);
        return notifications
            .OrderByDescending(n => n.CreatedAt)
            .Select(n => new NotificationDto(n.Id, n.Title, n.Body, n.NotificationType, n.IsRead, n.CreatedAt))
            .ToList();
    }

    public async Task<int> GetUnreadCountAsync()
    {
        var notifications = await _uow.Notifications.FindAsync(n => n.UserId == _currentUser.UserId && !n.IsRead);
        return notifications.Count;
    }

    public async Task MarkAsReadAsync(Guid id)
    {
        var notification = await _uow.Notifications.GetByIdAsync(id);
        if (notification == null || notification.UserId != _currentUser.UserId) return;

        notification.IsRead = true;
        _uow.Notifications.Update(notification);
        await _uow.SaveChangesAsync();
    }
}
