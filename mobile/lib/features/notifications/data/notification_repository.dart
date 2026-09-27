import '../../../core/network/api_client.dart';

class NotificationModel {
  final String id;
  final String title;
  final String? body;
  final String notificationType;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    this.body,
    required this.notificationType,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String?,
        notificationType: json['notificationType'] as String,
        isRead: json['isRead'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class NotificationRepository {
  final ApiClient _apiClient;
  NotificationRepository(this._apiClient);

  Future<List<NotificationModel>> getAll() async {
    final response = await _apiClient.dio.get('/notifications');
    return (response.data as List).map((e) => NotificationModel.fromJson(e)).toList();
  }

  Future<int> getUnreadCount() async {
    final response = await _apiClient.dio.get('/notifications/unread-count');
    return response.data['count'] as int;
  }

  Future<void> markAsRead(String id) => _apiClient.dio.patch('/notifications/$id/read');
}
