import '../../../core/network/api_client.dart';
import 'dashboard_model.dart';

class DashboardRepository {
  final ApiClient _apiClient;
  DashboardRepository(this._apiClient);

  Future<DashboardModel> getDashboard() async {
    final response = await _apiClient.dio.get('/dashboard');
    return DashboardModel.fromJson(response.data as Map<String, dynamic>);
  }
}
