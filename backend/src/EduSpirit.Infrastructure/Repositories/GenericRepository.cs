using System.Linq.Expressions;
using EduSpirit.Application.Interfaces;
using EduSpirit.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace EduSpirit.Infrastructure.Repositories;

public class GenericRepository<T> : IGenericRepository<T> where T : class
{
    private readonly AppDbContext _context;
    private readonly DbSet<T> _dbSet;

    public GenericRepository(AppDbContext context)
    {
        _context = context;
        _dbSet = context.Set<T>();
    }

    public async Task<T?> GetByIdAsync(Guid id)
    {
        // نستخدم FindAsync للاستفادة من الـ Change Tracker Cache عند توفره.
        return await _dbSet.FindAsync(id);
    }

    public async Task<List<T>> FindAsync(Expression<Func<T, bool>> predicate)
        => await _dbSet.Where(predicate).ToListAsync();

    public async Task<T?> FirstOrDefaultAsync(Expression<Func<T, bool>> predicate)
        => await _dbSet.FirstOrDefaultAsync(predicate);

    public async Task AddAsync(T entity) => await _dbSet.AddAsync(entity);

    public void Update(T entity) => _dbSet.Update(entity);

    public void Remove(T entity) => _dbSet.Remove(entity);

    public IQueryable<T> Query() => _dbSet.AsQueryable();
}
