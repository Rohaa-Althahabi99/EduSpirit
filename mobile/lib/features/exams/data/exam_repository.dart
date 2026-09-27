import '../../../core/network/api_client.dart';
import 'exam_model.dart';

class ExamRepository {
  final ApiClient _apiClient;
  ExamRepository(this._apiClient);

  Future<List<ExamModel>> getUpcoming() async {
    final response = await _apiClient.dio.get('/exams/upcoming');
    return (response.data as List).map((e) => ExamModel.fromJson(e)).toList();
  }

  Future<void> addChecklistItem(String examId, String content) =>
      _apiClient.dio.post('/exams/$examId/checklist', data: {'content': content});

  Future<void> toggleChecklistItem(String itemId, bool isDone) =>
      _apiClient.dio.patch('/exams/checklist/$itemId', queryParameters: {'isDone': isDone});
}
