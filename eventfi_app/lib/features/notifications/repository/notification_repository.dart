import 'package:dio/dio.dart';
import '../models/notification_model.dart';
import '../../../core/network/api_client.dart';

class NotificationRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<Map<String, dynamic>> getNotifications() async {
    final res = await _dio.get('/notifications');
    return {
      'notifications': (res.data['data']['notifications'] as List)
          .map((n) => NotificationModel.fromJson(n))
          .toList(),
      'unreadCount': res.data['data']['unreadCount'] ?? 0,
    };
  }

  Future<void> markRead(String id) async {
    await _dio.put('/notifications/$id/read');
  }

  Future<void> markAllRead() async {
    await _dio.put('/notifications/read-all');
  }

  Future<void> registerToken(String token) async {
    await _dio.post('/notifications/register-token', data: {'fcmToken': token});
  }
}
