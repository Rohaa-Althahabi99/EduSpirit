import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/course_model.dart';
import '../../data/course_repository.dart';

/// نقطة البداية الفعلية لأي طالب جديد — لازم يضيف موادّه هنا أولًا قبل أي شيء
/// (الجدول، الامتحانات، الواجبات، الحضور، الدرجات كلها ترتبط بمادة).
class CoursesScreen extends StatefulWidget {
  final CourseRepository repository;
  const CoursesScreen({super.key, required this.repository});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  List<CourseModel> _courses = [];
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
      _courses = await widget.repository.getAll();
    } catch (_) {
      _error = 'تعذّر تحميل المواد الدراسية.';
    }
    setState(() => _loading = false);
  }

  void _showCreateSheet() {
    final nameController = TextEditingController();
    final professorController = TextEditingController();
    int creditHours = 3;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.l, right: AppSpacing.l, top: AppSpacing.l,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.l,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('مادة دراسية جديدة', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: AppSpacing.m),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم المادة')),
              const SizedBox(height: AppSpacing.m),
              TextField(controller: professorController, decoration: const InputDecoration(labelText: 'اسم الأستاذ (اختياري)')),
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
                  const Text('الساعات المعتمدة:'),
                  const Spacer(),
                  IconButton(onPressed: () => setSheetState(() => creditHours = (creditHours - 1).clamp(1, 6)), icon: const Icon(Icons.remove_circle_outline)),
                  Text('$creditHours', style: const TextStyle(fontWeight: FontWeight.w700)),
                  IconButton(onPressed: () => setSheetState(() => creditHours = (creditHours + 1).clamp(1, 6)), icon: const Icon(Icons.add_circle_outline)),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) return;
                  await widget.repository.create(
                    name: nameController.text.trim(),
                    professorName: professorController.text.trim().isEmpty ? null : professorController.text.trim(),
                    creditHours: creditHours,
                  );
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                  _load();
                },
                child: const Text('إضافة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('موادّي الدراسية')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(children: [Padding(padding: const EdgeInsets.all(AppSpacing.xl), child: Center(child: Text(_error!)))])
                : _courses.isEmpty
                    ? ListView(children: const [Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: Center(child: Text('أضف موادّك الدراسية لتبدأ باستخدام الجدول والامتحانات والواجبات 🎓')),
                      )])
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.m),
                        itemCount: _courses.length,
                        itemBuilder: (context, index) {
                          final course = _courses[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: AppSpacing.m),
                            child: ListTile(
                              leading: Container(width: 6, height: 40, decoration: BoxDecoration(color: course.color, borderRadius: BorderRadius.circular(4))),
                              title: Text(course.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                              subtitle: Text('${course.professorName ?? "بدون أستاذ محدد"} · ${course.creditHours} ساعات'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20),
                                onPressed: () async {
                                  await widget.repository.delete(course.id);
                                  _load();
                                },
                              ),
                            ),
                          );
                        },
                      ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: _showCreateSheet, child: const Icon(Icons.add)),
    );
  }
}
