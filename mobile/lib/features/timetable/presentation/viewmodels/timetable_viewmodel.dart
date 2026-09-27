import 'package:flutter/foundation.dart';
import '../../data/timetable_entry_model.dart';
import '../../data/timetable_repository.dart';

enum LoadStatus { initial, loading, loaded, error }

class TimetableViewModel extends ChangeNotifier {
  final TimetableRepository _repository;
  TimetableViewModel(this._repository);

  LoadStatus status = LoadStatus.initial;
  List<TimetableEntryModel> todayEntries = [];
  List<TimetableEntryModel> weeklyEntries = [];
  String? errorMessage;

  Future<void> loadToday() async {
    status = LoadStatus.loading;
    notifyListeners();
    try {
      todayEntries = await _repository.getToday();
      status = LoadStatus.loaded;
    } catch (_) {
      status = LoadStatus.error;
      errorMessage = 'تعذّر تحميل جدول اليوم.';
    }
    notifyListeners();
  }

  Future<void> loadWeekly() async {
    status = LoadStatus.loading;
    notifyListeners();
    try {
      weeklyEntries = await _repository.getWeekly();
      status = LoadStatus.loaded;
    } catch (_) {
      status = LoadStatus.error;
      errorMessage = 'تعذّر تحميل الجدول الأسبوعي.';
    }
    notifyListeners();
  }

  /// إزالة تفاؤلية من الواجهة فورًا، مع تراجع تلقائي لو فشل الطلب على الخادم.
  Future<void> deleteEntry(String id) async {
    final backup = List<TimetableEntryModel>.from(todayEntries);
    todayEntries.removeWhere((e) => e.id == id);
    notifyListeners();
    try {
      await _repository.delete(id);
    } catch (_) {
      todayEntries = backup;
      notifyListeners();
    }
  }
}
