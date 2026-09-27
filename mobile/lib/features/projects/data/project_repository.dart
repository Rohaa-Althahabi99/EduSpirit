import '../../../core/network/api_client.dart';
import 'project_model.dart';

class ProjectRepository {
  final ApiClient _apiClient;
  ProjectRepository(this._apiClient);

  Future<List<ProjectModel>> getMine() async {
    final response = await _apiClient.dio.get('/projects');
    return (response.data as List).map((e) => ProjectModel.fromJson(e)).toList();
  }

  Future<void> create({required String title, String? description}) =>
      _apiClient.dio.post('/projects', data: {'title': title, 'description': description});

  Future<void> addMember(String projectId, String memberEmail) =>
      _apiClient.dio.post('/projects/$projectId/members', data: {'memberEmail': memberEmail});

  Future<void> addTask(String projectId, String title) =>
      _apiClient.dio.post('/projects/$projectId/tasks', data: {'title': title});

  Future<void> toggleTask(String taskId, bool isDone) =>
      _apiClient.dio.patch('/projects/tasks/$taskId', queryParameters: {'isDone': isDone});
}
