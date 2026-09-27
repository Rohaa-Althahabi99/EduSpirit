import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/schedule_tile.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../viewmodels/dashboard_viewmodel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().load();
    });
  }

  String _greetingPhrase() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير';
    if (hour < 18) return 'مساء الخير';
    return 'مساء الخير';
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => viewModel.refresh(),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.m),
            children: [
              _buildHeader(context, viewModel),
              const SizedBox(height: AppSpacing.l),
              if (viewModel.status == LoadStatus.loading) ..._buildSkeletons(),
              if (viewModel.status == LoadStatus.loaded && viewModel.data != null) ...[
                _buildTodaySchedule(context, viewModel),
                const SizedBox(height: AppSpacing.m),
                if (viewModel.data!.nextExam != null) _buildExamCountdown(context, viewModel),
                const SizedBox(height: AppSpacing.m),
                _buildQuickStats(context, viewModel),
              ],
              if (viewModel.status == LoadStatus.error)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Center(child: Text(viewModel.errorMessage ?? '')),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DashboardViewModel viewModel) {
    final name = viewModel.data?.greetingName ?? '';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${_greetingPhrase()}${name.isNotEmpty ? '، $name' : ''} 👋',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(
                _todayDateArabic(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primarySoft,
          child: const Icon(Icons.person, color: AppColors.primary),
        ),
      ],
    );
  }

  String _todayDateArabic() {
    const days = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
    final now = DateTime.now();
    return '${days[now.weekday - 1]}، ${now.day}/${now.month}/${now.year}';
  }

  Widget _buildTodaySchedule(BuildContext context, DashboardViewModel viewModel) {
    final entries = viewModel.data!.todaySchedule;
    return SectionCard(
      title: 'جدول اليوم',
      child: entries.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.m),
              child: Text('لا توجد محاضرات اليوم 🎉'),
            )
          : Column(children: entries.map((e) => ScheduleTile(entry: e)).toList()),
    );
  }

  Widget _buildExamCountdown(BuildContext context, DashboardViewModel viewModel) {
    final exam = viewModel.data!.nextExam!;
    return SectionCard(
      title: 'الامتحان القادم',
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: AppColors.accentOrange.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
            child: Center(
              child: Text('${exam.daysRemaining}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: AppColors.accentOrange)),
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exam.courseName, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text('${exam.examType} · ${exam.hallLocation ?? ''}',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, DashboardViewModel viewModel) {
    final data = viewModel.data!;
    return Row(
      children: [
        Expanded(child: _statTile(context, 'نسبة الحضور', '${data.attendancePercentage.toStringAsFixed(0)}%', AppColors.accentGreen)),
        const SizedBox(width: AppSpacing.m),
        Expanded(child: _statTile(context, 'مهام معلّقة', '${data.pendingTasksCount}', AppColors.accentPurple)),
      ],
    );
  }

  Widget _statTile(BuildContext context, String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSkeletons() => [
        const SkeletonBox(height: 110, borderRadius: BorderRadius.all(Radius.circular(16))),
        const SizedBox(height: AppSpacing.m),
        const SkeletonBox(height: 90, borderRadius: BorderRadius.all(Radius.circular(16))),
      ];
}
