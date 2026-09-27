using EduSpirit.Application.DTOs;
using EduSpirit.Application.Exceptions;
using EduSpirit.Application.Interfaces;
using EduSpirit.Domain.Entities;

namespace EduSpirit.Application.Services;

/// <summary>
/// كل الميزات الأخرى (الجدول، الامتحانات، الواجبات، الحضور، الدرجات) تعتمد على وجود
/// مادة دراسية مسبقًا — لذلك هذه الخدمة هي نقطة البداية الفعلية لأي مستخدم جديد.
/// </summary>
public class CourseService
{
    private readonly IUnitOfWork _uow;
    private readonly ICurrentUserService _currentUser;

    public CourseService(IUnitOfWork uow, ICurrentUserService currentUser)
    {
        _uow = uow;
        _currentUser = currentUser;
    }

    public async Task<CourseDto> CreateAsync(CreateCourseRequest request)
    {
        // لون افتراضي تلقائي بالتناوب لو المستخدم ما اختار لونًا — يحافظ على تناسق الجدول بصريًا.
        var existingCount = (await _uow.Courses.FindAsync(c => c.UserId == _currentUser.UserId && !c.IsDeleted)).Count;
        var palette = new[] { "#2F6FED", "#22C55E", "#F59E0B", "#8B5CF6", "#EF4444", "#06B6D4", "#EC4899" };

        var course = new Course
        {
            UserId = _currentUser.UserId,
            Name = request.Name.Trim(),
            Code = request.Code,
            ProfessorName = request.ProfessorName,
            ColorHex = request.ColorHex ?? palette[existingCount % palette.Length],
            CreditHours = request.CreditHours <= 0 ? 3 : request.CreditHours,
            Semester = request.Semester,
        };

        await _uow.Courses.AddAsync(course);
        await _uow.SaveChangesAsync();
        return ToDto(course);
    }

    public async Task<List<CourseDto>> GetAllAsync()
    {
        var courses = await _uow.Courses.FindAsync(c => c.UserId == _currentUser.UserId && !c.IsDeleted);
        return courses.OrderBy(c => c.Name).Select(ToDto).ToList();
    }

    public async Task<CourseDto> UpdateAsync(Guid id, UpdateCourseRequest request)
    {
        var course = await _uow.Courses.GetByIdAsync(id) ?? throw new NotFoundException("المادة الدراسية");
        if (course.UserId != _currentUser.UserId) throw new ForbiddenAppException();

        course.Name = request.Name.Trim();
        course.Code = request.Code;
        course.ProfessorName = request.ProfessorName;
        course.ColorHex = request.ColorHex ?? course.ColorHex;
        course.CreditHours = request.CreditHours;
        course.Semester = request.Semester;

        _uow.Courses.Update(course);
        await _uow.SaveChangesAsync();
        return ToDto(course);
    }

    public async Task DeleteAsync(Guid id)
    {
        var course = await _uow.Courses.GetByIdAsync(id) ?? throw new NotFoundException("المادة الدراسية");
        if (course.UserId != _currentUser.UserId) throw new ForbiddenAppException();

        // حذف ناعم فقط: أي جدول/امتحان/واجب مرتبط بهذه المادة يبقى تاريخيًا محفوظًا،
        // ولا يظهر فقط لأن Query Filter الخاص بالمادة سيُخفيها من نتائج البحث المستقبلية.
        course.IsDeleted = true;
        _uow.Courses.Update(course);
        await _uow.SaveChangesAsync();
    }

    private static CourseDto ToDto(Course c) =>
        new(c.Id, c.Name, c.Code, c.ProfessorName, c.ColorHex, c.CreditHours, c.Semester);
}
