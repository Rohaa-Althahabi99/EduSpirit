import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/exam_model.dart';
import '../../data/exam_repository.dart';

class ExamsScreen extends StatefulWidget {
  final ExamRepository repository;
  const ExamsScreen({super.key, required this.repository});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  List<ExamModel> _exams = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _exams = await widget.repository.getUpcoming();
    } catch (_) {
      _error = 'تعذّر تحميل الامتحانات.';
    }
    setState(() => _loading = false);
  }

  Color _difficultyColor(int level) {
    if (level >= 4) return AppColors.accentRed;
    if (level == 3) return AppColors.accentOrange;
    return AppColors.accentGreen;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الامتحانات القادمة')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(children: [Padding(padding: const EdgeInsets.all(AppSpacing.xl), child: Center(child: Text(_error!)))])
                : _exams.isEmpty
                    ? ListView(children: const [Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: Center(child: Text('لا توجد امتحانات مجدولة حاليًا 🎉')),
                      )])
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.m),
                        itemCount: _exams.length,
                        itemBuilder: (context, index) => _ExamCard(
                          exam: _exams[index],
                          difficultyColor: _difficultyColor(_exams[index].difficulty),
                          onToggleChecklistItem: (itemId, isDone) async {
                            await widget.repository.toggleChecklistItem(itemId, isDone);
                            _load();
                          },
                        ),
                      ),
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final ExamModel exam;
  final Color difficultyColor;
  final Function(String itemId, bool isDone) onToggleChecklistItem;

  const _ExamCard({required this.exam, required this.difficultyColor, required this.onToggleChecklistItem});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: AppColors.accentOrange.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text('${exam.daysRemaining}',
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.accentOrange))),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exam.courseName, style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text('${exam.examType} · ${exam.hallLocation ?? "القاعة غير محددة"}',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: difficultyColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text('صعوبة ${exam.difficulty}/5', style: TextStyle(color: difficultyColor, fontSize: 11)),
                ),
              ],
            ),
            if (exam.importantTopics != null) ...[
              const SizedBox(height: AppSpacing.s),
              Text('نقاط مهمة: ${exam.importantTopics}', style: const TextStyle(fontSize: 13)),
            ],
            if (exam.checklist.isNotEmpty) ...[
              const Divider(height: AppSpacing.l),
              const Text('قائمة التحضير', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ...exam.checklist.map((item) => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    value: item.isDone,
                    title: Text(item.content, style: const TextStyle(fontSize: 13)),
                    onChanged: (value) => onToggleChecklistItem(item.id, value ?? false),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
