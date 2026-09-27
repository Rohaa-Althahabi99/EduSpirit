using EduSpirit.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EduSpirit.API.Controllers;

[ApiController]
[Route("api/v1/notifications")]
[Authorize]
public class NotificationsController : ControllerBase
{
    private readonly NotificationService _notificationService;
    public NotificationsController(NotificationService notificationService) => _notificationService = notificationService;

    [HttpGet]
    public async Task<ActionResult<List<NotificationDto>>> GetAll() => Ok(await _notificationService.GetAllAsync());

    [HttpGet("unread-count")]
    public async Task<ActionResult<object>> UnreadCount() => Ok(new { count = await _notificationService.GetUnreadCountAsync() });

    [HttpPatch("{id:guid}/read")]
    public async Task<IActionResult> MarkAsRead(Guid id)
    {
        await _notificationService.MarkAsReadAsync(id);
        return NoContent();
    }
}
