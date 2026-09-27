using System.Linq.Expressions;

namespace EduSpirit.Application.Interfaces;

/// <summary>مستودع عام (Repository Pattern) لأي كيان — يوفر عمليات CRUD أساسية موحّدة.</summary>
public interface IGenericRepository<T> where T : class
{
    Task<T?> GetByIdAsync(Guid id);
    Task<List<T>> FindAsync(Expression<Func<T, bool>> predicate);
    Task<T?> FirstOrDefaultAsync(Expression<Func<T, bool>> predicate);
    Task AddAsync(T entity);
    void Update(T entity);
    void Remove(T entity);
    IQueryable<T> Query();
}
