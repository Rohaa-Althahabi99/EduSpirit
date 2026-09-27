import 'package:flutter/material.dart';
import '../../features/timetable/data/timetable_entry_model.dart';
import '../theme/app_spacing.dart';

class ScheduleTile extends StatelessWidget {
  final TimetableEntryModel entry;
  final VoidCallback? onTap;

  const ScheduleTile({super.key, required this.entry, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
        child: Row(
          children: [
            Container(width: 4, height: 44, decoration: BoxDecoration(
              color: entry.color, borderRadius: BorderRadius.circular(4),
            )),
            const SizedBox(width: AppSpacing.m),
            SizedBox(
              width: 60,
              child: Text(entry.startTime, style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              )),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                  if (entry.location != null)
                    Text(entry.location!, style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    )),
                ],
              ),
            ),
            Icon(Icons.chevron_left, color: theme.colorScheme.onSurface.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}
