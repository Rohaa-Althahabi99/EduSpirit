import '../../../core/network/api_client.dart';
import 'course_model.dart';

class CourseRepository {
  final ApiClient _apiClient;
  CourseRepository(this._apiClient);

  Future<List<CourseModel>> getAll() async {
    final response = await _apiClient.dio.get('/courses');
    return (response.data as List).map((e) => CourseModel.fromJson(e)).toList();
  }

  Future<CourseModel> create({
    required String name,
    String? code,
    String? professorName,
    required int creditHours,
    String? semester,
  }) async {
    final response = await _apiClient.dio.post('/courses', data: {
      'name': name,
      'code': code,
      'professorName': professorName,
      'creditHours': creditHours,
      'semester': semester,
    });
    return CourseModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(String id) => _apiClient.dio.delete('/courses/$id');
}
