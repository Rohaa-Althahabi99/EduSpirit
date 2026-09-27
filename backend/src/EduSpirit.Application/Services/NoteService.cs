using EduSpirit.Application.DTOs;
using EduSpirit.Application.Exceptions;
using EduSpirit.Application.Interfaces;
using EduSpirit.Domain.Entities;

namespace EduSpirit.Application.Services;

public class NoteService
{
    private readonly IUnitOfWork _uow;
    private readonly ICurrentUserService _currentUser;

    public NoteService(IUnitOfWork uow, ICurrentUserService currentUser)
    {
        _uow = uow;
        _currentUser = currentUser;
    }

    public async Task<NoteDto> CreateAsync(CreateNoteRequest request)
    {
        var note = new Note
        {
            UserId = _currentUser.UserId,
            Title = request.Title.Trim(),
            ContentRichText = request.ContentRichText,
            NoteType = request.NoteType,
            CourseId = request.CourseId,
            FolderName = request.FolderName,
            Tags = request.Tags,
        };
        await _uow.Notes.AddAsync(note);
        await _uow.SaveChangesAsync();

        var courseName = request.CourseId != null ? (await _uow.Courses.GetByIdAsync(request.CourseId.Value))?.Name : null;
        return ToDto(note, courseName);
    }

    public async Task<PagedResult<NoteDto>> SearchAsync(string? query, PageQuery paging)
    {
        var baseQuery = _uow.Notes.Query().Where(n => n.UserId == _currentUser.UserId && !n.IsDeleted);

        if (!string.IsNullOrWhiteSpace(query))
        {
            var q = query.Trim();
            baseQuery = baseQuery.Where(n => n.Title.Contains(q) || (n.Tags != null && n.Tags.Contains(q)));
        }

        var totalCount = baseQuery.Count();
        var page = paging.SafePage;
        var pageSize = paging.SafePageSize;

        var pageItems = baseQuery
            .OrderByDescending(n => n.UpdatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToList();

        var result = new List<NoteDto>();
        foreach (var n in pageItems)
        {
            var courseName = n.CourseId != null ? (await _uow.Courses.GetByIdAsync(n.CourseId.Value))?.Name : null;
            result.Add(ToDto(n, courseName));
        }

        return new PagedResult<NoteDto>(result, page, pageSize, totalCount);
    }

    public async Task DeleteAsync(Guid id)
    {
        var note = await _uow.Notes.GetByIdAsync(id) ?? throw new NotFoundException("الملاحظة");
        if (note.UserId != _currentUser.UserId) throw new ForbiddenAppException();

        note.IsDeleted = true;
        _uow.Notes.Update(note);
        await _uow.SaveChangesAsync();
    }

    private static NoteDto ToDto(Note n, string? courseName) => new(
        n.Id, n.Title, n.ContentRichText, n.NoteType, courseName, n.FolderName, n.Tags, n.UpdatedAt);
}
