import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/gpa_repository.dart';

class GpaScreen extends StatefulWidget {
  final GpaRepository repository;
  const GpaScreen({super.key, required this.repository});

  @override
  State<GpaScreen> createState() => _GpaScreenState();
}

class _GpaScreenState extends State<GpaScreen> {
  GpaResult? _result;
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
      _result = await widget.repository.get();
    } catch (_) {
      _error = 'تعذّر تحميل بيانات المعدل التراكمي.';
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حاسبة المعدل التراكمي')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(children: [Padding(padding: const EdgeInsets.all(AppSpacing.xl), child: Center(child: Text(_error!)))])
                : ListView(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    children: [
                      Row(
                        children: [
                          Expanded(child: _gpaCard('المعدل الفصلي', _result!.semesterGpa, AppColors.primary)),
                          const SizedBox(width: AppSpacing.m),
                          Expanded(child: _gpaCard('المعدل التراكمي', _result!.overallGpa, AppColors.accentPurple)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.m),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.m),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('إجمالي الساعات المعتمدة'),
                              Text('${_result!.totalCreditHours}', style: const TextStyle(fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.l),
                      Text('المعدل حسب الفصل', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: AppSpacing.s),
                      ..._result!.bySemester.map((s) => Card(
                            margin: const EdgeInsets.only(bottom: AppSpacing.s),
                            child: ListTile(
                              title: Text(s.semester),
                              subtitle: Text('${s.creditHours} ساعة معتمدة'),
                              trailing: Text(s.gpa.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.w800)),
                            ),
                          )),
                    ],
                  ),
      ),
    );
  }

  Widget _gpaCard(String label, double value, Color color) => Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            children: [
              Text(value.toStringAsFixed(2), style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color)),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
            ],
          ),
        ),
      );
}
