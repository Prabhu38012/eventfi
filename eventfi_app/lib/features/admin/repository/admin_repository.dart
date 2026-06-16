import 'package:dio/dio.dart';
import '../models/admin_stats_model.dart';
import '../../../core/network/api_client.dart';

class AdminRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<AdminStats> getStats() async {
    final res = await _dio.get('/admin/stats');
    return AdminStats.fromJson(res.data);
  }

  // Events
  Future<List<Map<String, dynamic>>> getEvents() async {
    final res = await _dio.get('/admin/events');
    return List<Map<String, dynamic>>.from(res.data['events'] ?? []);
  }

  Future<void> createEvent(Map<String, dynamic> data) async {
    await _dio.post('/admin/events', data: data);
  }

  Future<void> updateEvent(String id, Map<String, dynamic> data) async {
    await _dio.put('/admin/events/$id', data: data);
  }

  Future<void> deleteEvent(String id) async {
    await _dio.delete('/admin/events/$id');
  }

  // Bookings
  Future<Map<String, dynamic>> getBookings({String? status, int page = 1}) async {
    final res = await _dio.get('/admin/bookings',
        queryParameters: {'page': page, if (status != null) 'status': status});
    return {'bookings': List<Map<String, dynamic>>.from(res.data['bookings'] ?? []),
            'total':    res.data['total'] ?? 0};
  }

  Future<Map<String, dynamic>> scanBooking(String bookingId) async {
    final res = await _dio.get('/admin/bookings/scan/$bookingId');
    return res.data['booking'] as Map<String, dynamic>;
  }

  Future<void> markAttended(String bookingId) async {
    await _dio.put('/admin/bookings/$bookingId/attend');
  }

  // Coupons
  Future<List<Map<String, dynamic>>> getCoupons() async {
    final res = await _dio.get('/admin/coupons');
    return List<Map<String, dynamic>>.from(res.data['coupons'] ?? []);
  }

  Future<void> createCoupon(Map<String, dynamic> data) async {
    await _dio.post('/admin/coupons', data: data);
  }

  Future<void> toggleCoupon(String id) async {
    await _dio.put('/admin/coupons/$id/toggle');
  }

  Future<void> deleteCoupon(String id) async {
    await _dio.delete('/admin/coupons/$id');
  }
}
