import 'package:dio/dio.dart';
import '../models/review_model.dart';
import '../../../core/network/api_client.dart';

class ReviewRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<Map<String, dynamic>> getEventReviews(String eventId) async {
    final res = await _dio.get('/reviews/event/$eventId');
    return {
      'reviews':      (res.data['data']['reviews'] as List)
          .map((r) => ReviewModel.fromJson(r))
          .toList(),
      'avgRating':    (res.data['data']['avgRating'] ?? 0).toDouble(),
      'totalReviews': res.data['data']['totalReviews'] ?? 0,
    };
  }

  Future<ReviewModel> addReview({
    required String eventId,
    required int    rating,
    required String comment,
  }) async {
    final res = await _dio.post('/reviews', data: {
      'eventId': eventId,
      'rating':  rating,
      'comment': comment,
    });
    return ReviewModel.fromJson(res.data['data']['review']);
  }

  Future<void> deleteReview(String id) async {
    await _dio.delete('/reviews/$id');
  }
}
