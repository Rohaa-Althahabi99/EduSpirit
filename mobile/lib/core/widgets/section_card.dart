import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

/// بطاقة موحّدة تُستخدم في كل شاشات الداشبورد (جدول اليوم، الامتحان القادم، المهام...)
/// مع عنوان ورابط "عرض الكل" اختياري — لضمان اتساق بصري كامل عبر التطبيق.
class SectionCard extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  final Widget child;

  const SectionCard({super.key, required this.title, required this.child, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                ),
                if (onSeeAll != null)
                  TextButton(
                    onPressed: onSeeAll,
                    child: const Text('عرض الكل ←'),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            child,
          ],
        ),
      ),
    );
  }
}
