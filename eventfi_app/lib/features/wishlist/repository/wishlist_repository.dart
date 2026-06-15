import 'package:dio/dio.dart';
import '../../events/models/event_model.dart';
import '../../../core/network/api_client.dart';

class WishlistRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<EventModel>> getWishlist() async {
    final res = await _dio.get('/wishlist');
    return (res.data['data']['events'] as List)
        .map((e) => EventModel.fromJson(e))
        .toList();
  }

  Future<List<String>> getWishlistIds() async {
    final res = await _dio.get('/wishlist/ids');
    return List<String>.from(res.data['data']['ids'] ?? []);
  }

  Future<bool> toggle(String eventId) async {
    final res = await _dio.post('/wishlist/$eventId');
    return res.data['data']['added'] as bool;
  }
}
