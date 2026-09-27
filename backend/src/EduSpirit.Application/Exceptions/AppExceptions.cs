namespace EduSpirit.Application.Exceptions;

/// <summary>استثناء عام يُترجَم في الـ Middleware إلى رمز HTTP مناسب دون كشف تفاصيل داخلية.</summary>
public class AppException : Exception
{
    public int StatusCode { get; }
    public AppException(string message, int statusCode = 400) : base(message)
    {
        StatusCode = statusCode;
    }
}

public class NotFoundException : AppException
{
    public NotFoundException(string entity) : base($"{entity} غير موجود.", 404) { }
}

public class UnauthorizedAppException : AppException
{
    public UnauthorizedAppException(string message = "بيانات الدخول غير صحيحة.") : base(message, 401) { }
}

public class ConflictException : AppException
{
    public ConflictException(string message) : base(message, 409) { }
}

public class ForbiddenAppException : AppException
{
    public ForbiddenAppException(string message = "لا تملك صلاحية الوصول لهذا المورد.") : base(message, 403) { }
}
