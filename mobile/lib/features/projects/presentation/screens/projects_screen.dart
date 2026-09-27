import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/project_model.dart';
import '../../data/project_repository.dart';

class ProjectsScreen extends StatefulWidget {
  final ProjectRepository repository;
  const ProjectsScreen({super.key, required this.repository});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<ProjectModel> _projects = [];
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
      _projects = await widget.repository.getMine();
    } catch (_) {
      _error = 'تعذّر تحميل المشاريع.';
    }
    setState(() => _loading = false);
  }

  void _showCreateSheet() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

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
            const Text('مشروع جديد', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: AppSpacing.m),
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'عنوان المشروع')),
            const SizedBox(height: AppSpacing.m),
            TextField(controller: descController, maxLines: 3, decoration: const InputDecoration(labelText: 'الوصف (اختياري)')),
            const SizedBox(height: AppSpacing.m),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;
                await widget.repository.create(title: titleController.text.trim(), description: descController.text.trim());
                if (sheetContext.mounted) Navigator.pop(sheetContext);
                _load();
              },
              child: const Text('إنشاء'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المشاريع الجماعية')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(children: [Padding(padding: const EdgeInsets.all(AppSpacing.xl), child: Center(child: Text(_error!)))])
                : _projects.isEmpty
                    ? ListView(children: const [Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: Center(child: Text('لا توجد مشاريع بعد — أنشئ أول مشروع جماعي 🚀')),
                      )])
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.m),
                        itemCount: _projects.length,
                        itemBuilder: (context, index) => _ProjectCard(
                          project: _projects[index],
                          onAddTask: (title) async {
                            await widget.repository.addTask(_projects[index].id, title);
                            _load();
                          },
                          onToggleTask: (taskId, isDone) async {
                            await widget.repository.toggleTask(taskId, isDone);
                            _load();
                          },
                          onAddMember: (email) async {
                            await widget.repository.addMember(_projects[index].id, email);
                            _load();
                          },
                        ),
                      ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: _showCreateSheet, child: const Icon(Icons.add)),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final Function(String title) onAddTask;
  final Function(String taskId, bool isDone) onToggleTask;
  final Function(String email) onAddMember;

  const _ProjectCard({required this.project, required this.onAddTask, required this.onToggleTask, required this.onAddMember});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(project.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            if (project.description != null) Text(project.description!, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
            const SizedBox(height: AppSpacing.s),
            Row(
              children: [
                Expanded(child: LinearProgressIndicator(value: project.progressPercent / 100, minHeight: 8, borderRadius: BorderRadius.circular(8))),
                const SizedBox(width: AppSpacing.s),
                Text('${project.progressPercent}%'),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            Wrap(
              spacing: 6,
              children: project.members.map((m) => Chip(
                label: Text(m.fullName, style: const TextStyle(fontSize: 11)),
                avatar: const Icon(Icons.person, size: 14),
                backgroundColor: AppColors.primarySoft,
              )).toList(),
            ),
            if (project.tasks.isNotEmpty) ...[
              const Divider(height: AppSpacing.l),
              const Text('المهام', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ...project.tasks.map((t) => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    value: t.isDone,
                    title: Text(t.title, style: const TextStyle(fontSize: 13)),
                    onChanged: (value) => onToggleTask(t.id, value ?? false),
                  )),
            ],
            const SizedBox(height: AppSpacing.s),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add_task, size: 16),
                    label: const Text('مهمة'),
                    onPressed: () => _promptText(context, 'مهمة جديدة', 'عنوان المهمة', onAddTask),
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.person_add_alt, size: 16),
                    label: const Text('عضو'),
                    onPressed: () => _promptText(context, 'إضافة عضو', 'البريد الإلكتروني', onAddMember),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _promptText(BuildContext context, String title, String hint, Function(String) onSubmit) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(controller: controller, decoration: InputDecoration(hintText: hint)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              onSubmit(controller.text.trim());
              Navigator.pop(dialogContext);
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
