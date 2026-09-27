using System.Net;
using System.Text.Json;
using EduSpirit.Application.Exceptions;

namespace EduSpirit.API.Middleware;

/// <summary>
/// يلتقط كل استثناء غير معالَج قبل أن يصل للعميل، ويحوّله لاستجابة JSON موحّدة.
/// هذا يمنع تسريب Stack Trace أو أسماء الجداول/الأعمدة الداخلية لأي مهاجم.
/// </summary>
public class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionHandlingMiddleware> _logger;

    public ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (AppException appEx)
        {
            _logger.LogWarning(appEx, "Handled application exception");
            await WriteResponse(context, appEx.StatusCode, appEx.Message);
        }
        catch (Exception ex)
        {
            // أي استثناء غير متوقع: نسجّله بالتفصيل داخليًا فقط، ونرسل للعميل رسالة عامة.
            _logger.LogError(ex, "Unhandled exception");
            await WriteResponse(context, (int)HttpStatusCode.InternalServerError,
                "حدث خطأ غير متوقع في الخادم. حاول مرة أخرى لاحقًا.");
        }
    }

    private static async Task WriteResponse(HttpContext context, int statusCode, string message)
    {
        context.Response.ContentType = "application/json";
        context.Response.StatusCode = statusCode;
        var payload = JsonSerializer.Serialize(new { success = false, message });
        await context.Response.WriteAsync(payload);
    }
}
