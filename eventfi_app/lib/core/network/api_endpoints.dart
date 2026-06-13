import 'package:flutter/foundation.dart' show kIsWeb;

/// EventFi API Endpoints
/// ─────────────────────────────────────────────────────────────
/// baseUrl  → switches between web (localhost) and Android emulator (10.0.2.2)
/// Phase 10 → replace with your Render.com production URLs
class ApiEndpoints {
  ApiEndpoints._();

  // ─── Base URLs ──────────────────────────────────────────
  // Web (Chrome) → localhost  |  Android emulator → 10.0.2.2
  static String get baseUrl =>
      kIsWeb ? 'http://localhost:5000/api' : 'http://10.0.2.2:5000/api';

  static String get aiBaseUrl =>
      kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000';

  // ── PRODUCTION (uncomment in Phase 10) ──────────────────
  // static String get baseUrl   => 'https://eventfi-backend.onrender.com/api';
  // static String get aiBaseUrl => 'https://eventfi-ai.onrender.com';

  // ─── Auth ───────────────────────────────────────────────
  static const String login        = '/auth/login';
  static const String signup       = '/auth/signup';
  static const String me           = '/auth/me';
  static const String firebaseSync = '/auth/firebase';

  // ─── Events ─────────────────────────────────────────────
  static const String events       = '/events';
  static const String trending     = '/events/trending';
  static String eventById(String id) => '/events/$id';

  // ─── Booking ────────────────────────────────────────────
  static const String createBooking  = '/bookings';
  static const String myBookings     = '/bookings/my';
  static String cancelBooking(String id) => '/bookings/$id/cancel';
  static String verifyTicket(String id)  => '/bookings/$id/verify';

  // ─── Coupons ────────────────────────────────────────────
  static String validateCoupon(String code) => '/coupons/validate/$code';

  // ─── Points ─────────────────────────────────────────────
  static const String pointsBalance = '/points/balance';
  static const String pointsHistory = '/points/history';
  static const String redeemReward  = '/points/redeem';

  // ─── Reviews ────────────────────────────────────────────
  static String eventReviews(String eventId) => '/reviews/event/$eventId';
  static const String addReview = '/reviews';

  // ─── Wishlist ───────────────────────────────────────────
  static const String wishlist = '/wishlist';
  static String toggleWishlist(String eventId) => '/wishlist/$eventId';

  // ─── Notifications ──────────────────────────────────────
  static const String notifications  = '/notifications';
  static const String registerFcm   = '/notifications/register-token';

  // ─── Admin ──────────────────────────────────────────────
  static const String adminStats     = '/admin/stats';
  static const String adminEvents    = '/admin/events';
  static const String adminBookings  = '/admin/bookings';
  static const String adminCoupons   = '/admin/coupons';
  static const String adminRewards   = '/admin/rewards';
  static const String adminExportCsv = '/admin/export/bookings';

  // ─── AI Microservice ────────────────────────────────────
  static const String aiRecommend   = '/recommend';
  static const String aiSmartSearch = '/smart-search';
  static const String aiChat        = '/chat';
  static String aiDemand(String id) => '/demand/$id';
  static const String aiDetect      = '/detect';
  static const String aiSentiment   = '/sentiment';
}
