import 'package:flutter/foundation.dart';
import '../../data/dashboard_model.dart';
import '../../data/dashboard_repository.dart';

enum LoadStatus { initial, loading, loaded, error }

class DashboardViewModel extends ChangeNotifier {
  final DashboardRepository _repository;
  DashboardViewModel(this._repository);

  LoadStatus status = LoadStatus.initial;
  DashboardModel? data;
  String? errorMessage;

  Future<void> load() async {
    status = LoadStatus.loading;
    notifyListeners();
    try {
      data = await _repository.getDashboard();
      status = LoadStatus.loaded;
    } catch (_) {
      status = LoadStatus.error;
      errorMessage = 'تعذّر تحميل لوحة التحكم. اسحب للأسفل لإعادة المحاولة.';
    }
    notifyListeners();
  }

  Future<void> refresh() => load();
}
