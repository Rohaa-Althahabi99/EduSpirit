import 'package:flutter/foundation.dart';
import '../../data/assignment_model.dart';
import '../../data/assignment_repository.dart';

enum LoadStatus { initial, loading, loaded, error }

class AssignmentViewModel extends ChangeNotifier {
  final AssignmentRepository _repository;
  AssignmentViewModel(this._repository);

  LoadStatus status = LoadStatus.initial;
  List<AssignmentModel> assignments = [];
  String? errorMessage;

  Future<void> load() async {
    status = LoadStatus.loading;
    notifyListeners();
    try {
      assignments = await _repository.getAll();
      status = LoadStatus.loaded;
    } catch (_) {
      status = LoadStatus.error;
      errorMessage = 'تعذّر تحميل الواجبات.';
    }
    notifyListeners();
  }

  Future<void> createAssignment({
    required String title,
    required String assignmentType,
    String? description,
    required DateTime dueDate,
    required int priority,
  }) async {
    await _repository.create(
      title: title,
      assignmentType: assignmentType,
      description: description,
      dueDate: dueDate,
      priority: priority,
    );
    await load();
  }

  Future<void> markProgress(String id, int progressPercent) async {
    final status = progressPercent >= 100 ? 'submitted' : 'in_progress';
    await _repository.updateProgress(id, progressPercent, status);
    await load();
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    await load();
  }
}
