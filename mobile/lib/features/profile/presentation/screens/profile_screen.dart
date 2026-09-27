import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../attendance/data/attendance_repository.dart';
import '../../../attendance/presentation/screens/attendance_screen.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../courses/data/course_repository.dart';
import '../../../courses/presentation/screens/courses_screen.dart';
import '../../../projects/data/project_repository.dart';
import '../../../projects/presentation/screens/projects_screen.dart';
import '../../../notifications/data/notification_repository.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../../core/security/biometric_service.dart';
import '../../../gpa/data/gpa_repository.dart';
import '../../../gpa/presentation/screens/gpa_screen.dart';
import '../../../notes/data/note_repository.dart';
import '../../../notes/presentation/screens/notes_screen.dart';
import '../../../study/data/study_repository.dart';
import '../../../study/presentation/screens/study_mode_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final themeController = context.watch<ThemeController>();
    final user = authViewModel.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.m),
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 32, backgroundColor: AppColors.primarySoft,
                  child: Icon(Icons.person, color: AppColors.primary, size: 32)),
              const SizedBox(width: AppSpacing.m),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user?.fullName ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  Text(user?.email ?? '', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('فاتح'),
                  value: ThemeMode.light,
                  groupValue: themeController.mode,
                  onChanged: (m) => themeController.setMode(m!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('داكن'),
                  value: ThemeMode.dark,
                  groupValue: themeController.mode,
                  onChanged: (m) => themeController.setMode(m!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('حسب النظام'),
                  value: ThemeMode.system,
                  groupValue: themeController.mode,
                  onChanged: (m) => themeController.setMode(m!),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          _BiometricToggleCard(biometricService: context.read<BiometricService>()),
          const SizedBox(height: AppSpacing.l),
          Text('المزيد', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.s),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.menu_book_outlined, color: AppColors.primary),
                  title: const Text('موادّي الدراسية'),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => CoursesScreen(repository: context.read<CourseRepository>()),
                  )),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.timer_outlined, color: AppColors.primary),
                  title: const Text('وضع الدراسة (بومودورو)'),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => StudyModeScreen(repository: context.read<StudyRepository>()),
                  )),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.fact_check_outlined, color: AppColors.accentGreen),
                  title: const Text('الحضور'),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => AttendanceScreen(repository: context.read<AttendanceRepository>()),
                  )),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.school_outlined, color: AppColors.accentPurple),
                  title: const Text('حاسبة المعدل التراكمي'),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => GpaScreen(repository: context.read<GpaRepository>()),
                  )),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.note_alt_outlined, color: AppColors.accentOrange),
                  title: const Text('الملاحظات'),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => NotesScreen(repository: context.read<NoteRepository>()),
                  )),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.groups_outlined, color: AppColors.primary),
                  title: const Text('المشاريع الجماعية'),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ProjectsScreen(repository: context.read<ProjectRepository>()),
                  )),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined, color: AppColors.accentRed),
                  title: const Text('الإشعارات'),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => NotificationsScreen(repository: context.read<NotificationRepository>()),
                  )),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentRed),
            onPressed: () => authViewModel.logout(),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}

class _BiometricToggleCard extends StatefulWidget {
  final BiometricService biometricService;
  const _BiometricToggleCard({required this.biometricService});

  @override
  State<_BiometricToggleCard> createState() => _BiometricToggleCardState();
}

class _BiometricToggleCardState extends State<_BiometricToggleCard> {
  bool _supported = false;
  bool _enabled = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final supported = await widget.biometricService.isDeviceSupported;
    final enabled = await widget.biometricService.isEnabledByUser;
    setState(() { _supported = supported; _enabled = enabled; _loaded = true; });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || !_supported) return const SizedBox.shrink();

    return Card(
      child: SwitchListTile(
        secondary: const Icon(Icons.fingerprint, color: AppColors.primary),
        title: const Text('قفل التطبيق بالبصمة / Face ID'),
        subtitle: const Text('طبقة حماية إضافية عند فتح التطبيق'),
        value: _enabled,
        onChanged: (value) async {
          if (value) {
            final confirmed = await widget.biometricService.authenticate();
            if (!confirmed) return;
          }
          await widget.biometricService.setEnabled(value);
          setState(() => _enabled = value);
        },
      ),
    );
  }
}
