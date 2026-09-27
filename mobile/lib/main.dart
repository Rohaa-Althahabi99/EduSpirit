import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/network/secure_token_storage.dart';
import 'core/security/biometric_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/widgets/biometric_gate.dart';
import 'core/widgets/main_shell.dart';

import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';

import 'features/dashboard/data/dashboard_repository.dart';
import 'features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart';

import 'features/timetable/data/timetable_repository.dart';
import 'features/timetable/presentation/viewmodels/timetable_viewmodel.dart';

import 'features/assignments/data/assignment_repository.dart';
import 'features/assignments/presentation/viewmodels/assignment_viewmodel.dart';

import 'features/exams/data/exam_repository.dart';
import 'features/attendance/data/attendance_repository.dart';
import 'features/study/data/study_repository.dart';
import 'features/gpa/data/gpa_repository.dart';
import 'features/notes/data/note_repository.dart';
import 'features/courses/data/course_repository.dart';
import 'features/projects/data/project_repository.dart';
import 'features/notifications/data/notification_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // يهيّئ التخزين المحلي المستخدم في Offline Mode
  runApp(const EduSpiritApp());
}

class EduSpiritApp extends StatelessWidget {
  const EduSpiritApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ------------- تركيب طبقات البيانات (Composition Root) -------------
    // هنا فقط نبني الاعتماديات يدويًا (بدون DI framework إضافي) — طبقة واحدة
    // تعرف كيف تُركَّب الأشياء، وباقي التطبيق لا يعرف شيئًا عن هذا التفصيل.
    final tokenStorage = SecureTokenStorage();
    final apiClient = ApiClient(tokenStorage);
    final biometricService = BiometricService();

    final authRepository = AuthRepository(apiClient, tokenStorage);
    final dashboardRepository = DashboardRepository(apiClient);
    final timetableRepository = TimetableRepository(apiClient);
    final assignmentRepository = AssignmentRepository(apiClient);
    final examRepository = ExamRepository(apiClient);
    final attendanceRepository = AttendanceRepository(apiClient);
    final studyRepository = StudyRepository(apiClient);
    final gpaRepository = GpaRepository(apiClient);
    final noteRepository = NoteRepository(apiClient);
    final courseRepository = CourseRepository(apiClient);
    final projectRepository = ProjectRepository(apiClient);
    final notificationRepository = NotificationRepository(apiClient);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()..loadSavedTheme()),
        ChangeNotifierProvider(create: (_) => AuthViewModel(authRepository)..checkSession()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel(dashboardRepository)),
        ChangeNotifierProvider(create: (_) => TimetableViewModel(timetableRepository)),
        ChangeNotifierProvider(create: (_) => AssignmentViewModel(assignmentRepository)),
        Provider<ExamRepository>.value(value: examRepository),
        Provider<AttendanceRepository>.value(value: attendanceRepository),
        Provider<StudyRepository>.value(value: studyRepository),
        Provider<GpaRepository>.value(value: gpaRepository),
        Provider<NoteRepository>.value(value: noteRepository),
        Provider<CourseRepository>.value(value: courseRepository),
        Provider<ProjectRepository>.value(value: projectRepository),
        Provider<NotificationRepository>.value(value: notificationRepository),
        Provider<BiometricService>.value(value: biometricService),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) {
          return MaterialApp(
            title: 'EduSpirit',
            debugShowCheckedModeBanner: false,
            themeMode: themeController.mode,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            locale: const Locale('ar'),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('ar'), Locale('en')],
            builder: (context, child) => Directionality(
              textDirection: TextDirection.rtl, // دعم كامل للـ RTL بحسب المتطلبات
              child: child!,
            ),
            home: const _RootGate(),
          );
        },
      ),
    );
  }
}

/// يقرّر أي شاشة تظهر أولًا: شاشة الدخول أو الواجهة الرئيسية — بناءً على وجود جلسة مخزّنة.
class _RootGate extends StatelessWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    switch (authViewModel.status) {
      case AuthStatus.initial:
      case AuthStatus.loading:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AuthStatus.authenticated:
        return BiometricGate(
          biometricService: context.read<BiometricService>(),
          child: const MainShell(),
        );
      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        return LoginScreen(onLoggedIn: () {});
    }
  }
}