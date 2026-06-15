import 'package:dio/dio.dart';
import '../models/booking_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class BookingRepository {
  final Dio _dio = ApiClient.instance.dio;

  /// Step 1 — Create Razorpay order before showing payment
  Future<Map<String, dynamic>> createOrder({
    required String eventId,
    required int    seats,
    String?         couponCode,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.createBooking.replaceAll('/bookings', '/bookings/create-order'),
      data: {
        'eventId':    eventId,
        'seats':      seats,
        'couponCode': couponCode,
      },
    );
    return res.data as Map<String, dynamic>;
  }

  /// Step 2 — Verify payment + create booking
  Future<Map<String, dynamic>> verifyAndBook({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String eventId,
    required int    seats,
    required double amount,
    required double discount,
    required double finalAmount,
    String?         couponCode,
  }) async {
    final res = await _dio.post(
      '/bookings/verify',
      data: {
        'razorpayOrderId':   razorpayOrderId,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpaySignature': razorpaySignature,
        'eventId':           eventId,
        'seats':             seats,
        'amount':            amount,
        'discount':          discount,
        'finalAmount':       finalAmount,
        'couponCode':        couponCode,
      },
    );
    return res.data as Map<String, dynamic>;
  }

  /// Validate a coupon code
  Future<Map<String, dynamic>> validateCoupon({
    required String code,
    required double amount,
  }) async {
    final res = await _dio.post(
      '/coupons/validate',
      data: {'code': code, 'amount': amount},
    );
    return res.data as Map<String, dynamic>;
  }

  /// Get logged-in user's bookings
  Future<List<BookingModel>> getMyBookings() async {
    final res = await _dio.get(ApiEndpoints.myBookings);
    return (res.data['bookings'] as List)
        .map((b) => BookingModel.fromJson(b))
        .toList();
  }

  /// Get single booking by ID
  Future<BookingModel> getBookingById(String id) async {
    final res = await _dio.get('/bookings/$id');
    return BookingModel.fromJson(res.data['booking']);
  }

  /// Cancel booking
  Future<void> cancelBooking(String id) async {
    await _dio.delete('/bookings/$id');
  }
}
