import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/attendance_repository.dart';

class AttendanceScreen extends StatefulWidget {
  final AttendanceRepository repository;
  const AttendanceScreen({super.key, required this.repository});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<CourseAttendanceStats> _stats = [];
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
      _stats = await widget.repository.getStats();
    } catch (_) {
      _error = 'تعذّر تحميل بيانات الحضور.';
    }
    setState(() => _loading = false);
  }

  Color _colorFor(double percentage) {
    if (percentage >= 85) return AppColors.accentGreen;
    if (percentage >= 70) return AppColors.accentOrange;
    return AppColors.accentRed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الحضور')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(children: [Padding(padding: const EdgeInsets.all(AppSpacing.xl), child: Center(child: Text(_error!)))])
                : _stats.isEmpty
                    ? ListView(children: const [Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: Center(child: Text('لا توجد بيانات حضور بعد.')),
                      )])
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.m),
                        itemCount: _stats.length,
                        itemBuilder: (context, index) {
                          final s = _stats[index];
                          final color = _colorFor(s.attendancePercentage);
                          return Card(
                            margin: const EdgeInsets.only(bottom: AppSpacing.m),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.m),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 56, height: 56,
                                    child: Stack(alignment: Alignment.center, children: [
                                      CircularProgressIndicator(
                                        value: s.attendancePercentage / 100,
                                        strokeWidth: 6,
                                        backgroundColor: color.withOpacity(0.15),
                                        valueColor: AlwaysStoppedAnimation(color),
                                      ),
                                      Text('${s.attendancePercentage.toStringAsFixed(0)}%',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                    ]),
                                  ),
                                  const SizedBox(width: AppSpacing.m),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(s.courseName, style: const TextStyle(fontWeight: FontWeight.w700)),
                                        const SizedBox(height: 4),
                                        Text('حاضر ${s.presentCount} · غائب ${s.absentCount} · متأخر ${s.lateCount}',
                                            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                                        if (s.attendancePercentage < 75) ...[
                                          const SizedBox(height: 4),
                                          const Text('⚠️ تنبيه: نسبة حضورك منخفضة',
                                              style: TextStyle(fontSize: 11, color: AppColors.accentRed, fontWeight: FontWeight.w600)),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
