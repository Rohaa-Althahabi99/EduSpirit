using EduSpirit.Application.Interfaces;

namespace EduSpirit.Infrastructure.Identity;

/// <summary>
/// يستخدم BCrypt.Net-Next (حزمة NuGet: BCrypt.Net-Next). Work Factor = 12
/// يوازن بين الأمان وزمن الاستجابة المقبول على السيرفر.
/// </summary>
public class PasswordHasher : IPasswordHasher
{
    private const int WorkFactor = 12;

    public string Hash(string plainPassword) =>
        BCrypt.Net.BCrypt.HashPassword(plainPassword, workFactor: WorkFactor);

    public bool Verify(string plainPassword, string hash)
    {
        try
        {
            return BCrypt.Net.BCrypt.Verify(plainPassword, hash);
        }
        catch
        {
            // أي هاش تالف/غير متوافق يُعامَل كفشل تحقق، وليس استثناء يكشف تفاصيل داخلية.
            return false;
        }
    }
}
