using EduSpirit.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace EduSpirit.Infrastructure.Persistence.Configurations;

public class TimetableEntryConfiguration : IEntityTypeConfiguration<TimetableEntry>
{
    public void Configure(EntityTypeBuilder<TimetableEntry> builder)
    {
        builder.ToTable("TimetableEntries");
        builder.Property(t => t.Title).HasMaxLength(200).IsRequired();
        builder.Property(t => t.EntryType).HasConversion<string>().HasMaxLength(20);

        builder.HasOne(t => t.Course)
               .WithMany(c => c.TimetableEntries)
               .HasForeignKey(t => t.CourseId)
               .OnDelete(DeleteBehavior.SetNull);

        builder.HasIndex(t => new { t.UserId, t.DayOfWeek });
    }
}
