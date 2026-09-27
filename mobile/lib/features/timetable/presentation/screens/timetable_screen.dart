import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/schedule_tile.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../data/timetable_entry_model.dart';
import '../viewmodels/timetable_viewmodel.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _weekDays = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimetableViewModel>().loadWeekly();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TimetableViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الجدول الذكي'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'أسبوعي'), Tab(text: 'حسب اليوم')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWeeklyView(viewModel),
          _buildGroupedByDayView(viewModel),
        ],
      ),
    );
  }

  Widget _buildWeeklyView(TimetableViewModel viewModel) {
    if (viewModel.status == LoadStatus.loading) {
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.m),
        children: List.generate(5, (_) => const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.m),
              child: SkeletonBox(height: 64, borderRadius: BorderRadius.all(Radius.circular(12))),
            )),
      );
    }

    if (viewModel.weeklyEntries.isEmpty) {
      return const Center(child: Text('لا توجد محاضرات مضافة بعد.'));
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.loadWeekly(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.m),
        itemCount: viewModel.weeklyEntries.length,
        itemBuilder: (context, index) => ScheduleTile(entry: viewModel.weeklyEntries[index]),
      ),
    );
  }

  Widget _buildGroupedByDayView(TimetableViewModel viewModel) {
    final Map<int, List<TimetableEntryModel>> grouped = {};
    for (final entry in viewModel.weeklyEntries) {
      final day = entry.dayOfWeek ?? 0;
      grouped.putIfAbsent(day, () => []).add(entry);
    }

    if (viewModel.status == LoadStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.loadWeekly(),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.m),
        children: List.generate(7, (i) {
          final dayNumber = i + 1;
          final entries = grouped[dayNumber] ?? [];
          if (entries.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.m),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(_weekDays[dayNumber - 1], style: const TextStyle(fontWeight: FontWeight.w700)),
                    ...entries.map((e) => ScheduleTile(entry: e)),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
