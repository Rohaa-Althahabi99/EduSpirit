import '../../../core/network/api_client.dart';

class StudyRepository {
  final ApiClient _apiClient;
  StudyRepository(this._apiClient);

  Future<String> startSession(String mode) async {
    final response = await _apiClient.dio.post('/study/start', data: {'mode': mode});
    return response.data['sessionId'] as String;
  }

  Future<void> endSession(String sessionId) =>
      _apiClient.dio.post('/study/end', data: {'sessionId': sessionId});

  Future<Map<String, dynamic>> getStreak() async {
    final response = await _apiClient.dio.get('/study/streak');
    return response.data as Map<String, dynamic>;
  }
}
