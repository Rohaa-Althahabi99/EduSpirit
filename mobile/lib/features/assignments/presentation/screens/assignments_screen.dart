import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/assignment_model.dart';
import '../viewmodels/assignment_viewmodel.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AssignmentViewModel>().load());
  }

  Color _priorityColor(int priority) {
    if (priority >= 4) return AppColors.accentRed;
    if (priority == 3) return AppColors.accentOrange;
    return AppColors.accentGreen;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AssignmentViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('الواجبات والمهام')),
      body: RefreshIndicator(
        onRefresh: () => viewModel.load(),
        child: switch (viewModel.status) {
          LoadStatus.loading => const Center(child: CircularProgressIndicator()),
          LoadStatus.error => ListView(children: [Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(child: Text(viewModel.errorMessage ?? '')),
            )]),
          _ => viewModel.assignments.isEmpty
              ? ListView(children: const [Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Center(child: Text('لا توجد واجبات حاليًا 🎉')),
                )])
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  itemCount: viewModel.assignments.length,
                  itemBuilder: (context, index) => _AssignmentCard(
                    assignment: viewModel.assignments[index],
                    priorityColor: _priorityColor(viewModel.assignments[index].priority),
                    onProgressChanged: (value) =>
                        viewModel.markProgress(viewModel.assignments[index].id, value),
                    onDelete: () => viewModel.delete(viewModel.assignments[index].id),
                  ),
                ),
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    final viewModel = context.read<AssignmentViewModel>();
    final titleController = TextEditingController();
    DateTime dueDate = DateTime.now().add(const Duration(days: 3));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.l, right: AppSpacing.l, top: AppSpacing.l,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.l,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('واجب جديد', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: AppSpacing.m),
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'عنوان الواجب')),
            const SizedBox(height: AppSpacing.m),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;
                await viewModel.createAssignment(
                  title: titleController.text.trim(),
                  assignmentType: 'homework',
                  dueDate: dueDate,
                  priority: 3,
                );
                if (sheetContext.mounted) Navigator.pop(sheetContext);
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final AssignmentModel assignment;
  final Color priorityColor;
  final ValueChanged<int> onProgressChanged;
  final VoidCallback onDelete;

  const _AssignmentCard({
    required this.assignment,
    required this.priorityColor,
    required this.onProgressChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final daysLeft = assignment.dueDate.difference(DateTime.now()).inDays;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: priorityColor, shape: BoxShape.circle)),
                const SizedBox(width: AppSpacing.s),
                Expanded(child: Text(assignment.title, style: const TextStyle(fontWeight: FontWeight.w700))),
                IconButton(icon: const Icon(Icons.delete_outline, size: 20), onPressed: onDelete),
              ],
            ),
            if (assignment.courseName != null)
              Text(assignment.courseName!, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
            const SizedBox(height: AppSpacing.s),
            Text(daysLeft >= 0 ? 'متبقي $daysLeft يوم' : 'متأخر', style: TextStyle(
              color: daysLeft < 0 ? AppColors.accentRed : Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 12,
            )),
            const SizedBox(height: AppSpacing.s),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: assignment.progressPercent / 100,
                    borderRadius: BorderRadius.circular(8),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                Text('${assignment.progressPercent}%'),
              ],
            ),
            Slider(
              value: assignment.progressPercent.toDouble(),
              min: 0, max: 100, divisions: 20,
              onChanged: (v) => onProgressChanged(v.round()),
            ),
          ],
        ),
      ),
    );
  }
}
