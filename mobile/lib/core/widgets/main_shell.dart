import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/assignments/presentation/screens/assignments_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/exams/data/exam_repository.dart';
import '../../features/exams/presentation/screens/exams_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/timetable/presentation/screens/timetable_screen.dart';

/// الهيكل الرئيسي بعد تسجيل الدخول: شريط تنقل سفلي بخمس وجهات مطابق للتصميم
/// (الرئيسية، الجدول، زر إضافة سريع في المنتصف، المهام، الحساب).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  // شاشات الوجهات الأربع الأساسية في شريط التنقل السفلي.
  final _screens = const [
    DashboardScreen(),
    TimetableScreen(),
    AssignmentsScreen(),
    ProfileScreen(),
  ];

  void _onQuickAddPressed() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _QuickAddSheet(
        onSelectTimetable: () => setState(() => _selectedIndex = 1),
        onSelectTasks: () => setState(() => _selectedIndex = 2),
        onOpenExams: () {
          final examRepository = context.read<ExamRepository>();
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ExamsScreen(repository: examRepository),
          ));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // نضع شاشة الملف الشخصي كآخر عنصر بينما زر + في المنتصف بصريًا فقط.
    final navItems = const [
      BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'الرئيسية'),
      BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'الجدول'),
      BottomNavigationBarItem(icon: Icon(Icons.checklist_rounded), label: 'المهام'),
      BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'حسابي'),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      floatingActionButton: FloatingActionButton(
        onPressed: _onQuickAddPressed,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(navItems.length, (index) {
            // نُدخل فراغًا في المنتصف مكان الـ FAB
            final adjustedIndex = index < 2 ? index : index;
            return Expanded(
              child: InkWell(
                onTap: () => setState(() => _selectedIndex = adjustedIndex),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        (navItems[index].icon as Icon).icon,
                        color: _selectedIndex == adjustedIndex
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                      Text(navItems[index].label!,
                          style: TextStyle(
                            fontSize: 11,
                            color: _selectedIndex == adjustedIndex
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          )),
                    ],
                  ),
                ),
              ),
            );
          })
            ..insert(2, const Expanded(child: SizedBox())), // فراغ مكان زر الإضافة العائم
        ),
      ),
    );
  }
}

class _QuickAddSheet extends StatelessWidget {
  final VoidCallback onSelectTimetable;
  final VoidCallback onSelectTasks;
  final VoidCallback onOpenExams;

  const _QuickAddSheet({
    required this.onSelectTimetable,
    required this.onSelectTasks,
    required this.onOpenExams,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('إضافة سريعة', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.event_note_rounded),
              title: const Text('محاضرة جديدة'),
              subtitle: const Text('انتقل لتبويب الجدول لإضافتها'),
              onTap: () {
                Navigator.pop(context);
                onSelectTimetable();
              },
            ),
            ListTile(
              leading: const Icon(Icons.task_alt_rounded),
              title: const Text('مهمة أو واجب جديد'),
              onTap: () {
                Navigator.pop(context);
                onSelectTasks();
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book_rounded),
              title: const Text('عرض الامتحانات القادمة'),
              onTap: () {
                Navigator.pop(context);
                onOpenExams();
              },
            ),
          ],
        ),
      ),
    );
  }
}
