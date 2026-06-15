// Conditional export:
//   on web  → payment_web_impl.dart (uses dart:js + Razorpay checkout.js)
//   on mobile → payment_web_stub.dart (no-op, never called)
export 'payment_web_stub.dart'
    if (dart.library.html) 'payment_web_impl.dart';
