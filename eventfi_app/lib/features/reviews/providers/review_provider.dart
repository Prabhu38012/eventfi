import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/review_model.dart';
import '../repository/review_repository.dart';

class ReviewProvider extends ChangeNotifier {
  final _repo = ReviewRepository();

  List<ReviewModel> _reviews      = [];
  double            _avgRating    = 0;
  int               _totalReviews = 0;
  bool              _loading      = false;
  bool              _submitting   = false;
  String?           _error;
  bool              _submitted    = false;

  List<ReviewModel> get reviews      => _reviews;
  double            get avgRating    => _avgRating;
  int               get totalReviews => _totalReviews;
  bool              get loading      => _loading;
  bool              get submitting   => _submitting;
  String?           get error        => _error;
  bool              get submitted    => _submitted;

  Future<void> loadReviews(String eventId) async {
    _loading = true; _error = null; notifyListeners();
    try {
      final data    = await _repo.getEventReviews(eventId);
      _reviews      = data['reviews']      as List<ReviewModel>;
      _avgRating    = data['avgRating']    as double;
      _totalReviews = data['totalReviews'] as int;
    } catch (e) {
      _error = 'Failed to load reviews';
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<bool> submitReview({
    required String eventId,
    required int    rating,
    required String comment,
  }) async {
    _submitting = true; _error = null; notifyListeners();
    try {
      final review = await _repo.addReview(
        eventId: eventId, rating: rating, comment: comment,
      );
      _reviews.insert(0, review);
      _totalReviews++;
      _avgRating = _reviews.map((r) => r.rating).reduce((a, b) => a + b) / _reviews.length;
      _avgRating = double.parse(_avgRating.toStringAsFixed(1));
      _submitted = true;
      return true;
    } catch (e) {
      String msg = 'Failed to submit review. Try again.';
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data['message'] != null) {
          msg = data['message'];
        }
      }
      _error = msg;
      return false;
    } finally {
      _submitting = false; notifyListeners();
    }
  }
}
