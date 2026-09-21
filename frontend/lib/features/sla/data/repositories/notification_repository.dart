import 'package:smart_campus_issue_manager/core/network/api_client.dart';
import '../models/sla_models.dart';

class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // Get user notifications
  Future<List<NotificationModel>> getNotifications() async {
    final response = await _apiClient.get('/notifications');
    if (response is List) {
      return response.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // Get unread count
  Future<int> getUnreadCount() async {
    final response = await _apiClient.get('/notifications/unread-count');
    if (response is Map<String, dynamic>) {
      return (response['unreadCount'] as num?)?.toInt() ?? 0;
    }
    return 0;
  }

  // Mark single notification read
  Future<void> markAsRead(String id) async {
    await _apiClient.patch('/notifications/$id/read', {});
  }

  // Mark all read
  Future<void> markAllAsRead() async {
    await _apiClient.patch('/notifications/read-all', {});
  }
}
