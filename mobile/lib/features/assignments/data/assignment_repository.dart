import '../../../core/network/api_client.dart';
import 'assignment_model.dart';

class AssignmentRepository {
  final ApiClient _apiClient;
  AssignmentRepository(this._apiClient);

  Future<List<AssignmentModel>> getAll() async {
    final response = await _apiClient.dio.get('/assignments');
    return (response.data as List).map((e) => AssignmentModel.fromJson(e)).toList();
  }

  Future<void> create({
    required String title,
    String? courseId,
    required String assignmentType,
    String? description,
    required DateTime dueDate,
    required int priority,
  }) async {
    await _apiClient.dio.post('/assignments', data: {
      'title': title,
      'courseId': courseId,
      'assignmentType': assignmentType,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority,
    });
  }

  Future<void> updateProgress(String id, int progressPercent, String status) async {
    await _apiClient.dio.patch('/assignments/$id/progress', data: {
      'progressPercent': progressPercent,
      'status': status,
    });
  }

  Future<void> delete(String id) => _apiClient.dio.delete('/assignments/$id');
}
