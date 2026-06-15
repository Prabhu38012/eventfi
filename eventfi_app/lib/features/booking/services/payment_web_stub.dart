import 'dart:async';

/// Stub for mobile — this function is never called on Android/iOS.
/// The real implementation is in payment_web_impl.dart (web only).
Future<Map<String, String>?> razorpayWebCheckout(
    String key, String orderId, int paise) async => null;
