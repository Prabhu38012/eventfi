import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../models/booking_model.dart';
import '../repository/booking_repository.dart';
import '../services/payment_web.dart'; // conditional: web impl or mobile stub

class BookingProvider extends ChangeNotifier {
  final _repo = BookingRepository();

  // ── Razorpay (mobile only — null on web) ────────────────────
  Razorpay? _razorpay;

  // ── Seat selection ──────────────────────────────────────────
  int    _selectedSeats = 1;
  double _pricePerSeat  = 0;

  // ── Coupon ──────────────────────────────────────────────────
  String? _couponCode;
  double  _discount      = 0;
  String? _couponMessage;
  bool    _couponLoading = false;
  bool    _couponValid   = false;

  // ── Order / payment ──────────────────────────────────────────
  bool    _creatingOrder   = false;
  String? _razorpayOrderId;
  String? _razorpayKeyId;

  // ── Result ───────────────────────────────────────────────────
  bool          _verifying    = false;
  BookingModel? _booking;
  int           _pointsEarned = 0;
  bool          _confirmed    = false;
  String?       _error;

  // ── Booking history ──────────────────────────────────────────
  List<BookingModel> _myBookings  = [];
  bool               _histLoading = false;

  // ── Pending booking data (used by verify) ────────────────────
  String? _pendingEventId;
  int?    _pendingSeats;
  double? _pendingAmount;
  double? _pendingDiscount;
  double? _pendingFinalAmount;
  String? _pendingCouponCode;

  // ── Getters ──────────────────────────────────────────────────
  int    get selectedSeats  => _selectedSeats;
  double get pricePerSeat   => _pricePerSeat;
  double get baseAmount     => _selectedSeats * _pricePerSeat;
  double get discount       => _discount;
  double get finalAmount    => baseAmount - _discount;
  String? get couponCode    => _couponCode;
  String? get couponMessage => _couponMessage;
  bool    get couponLoading => _couponLoading;
  bool    get couponValid   => _couponValid;
  bool    get creatingOrder => _creatingOrder;
  bool    get verifying     => _verifying;
  bool    get confirmed     => _confirmed;
  String? get error         => _error;
  BookingModel? get booking => _booking;
  int     get pointsEarned  => _pointsEarned;
  List<BookingModel> get myBookings  => _myBookings;
  bool               get histLoading => _histLoading;

  // ── Init ─────────────────────────────────────────────────────
  void init(double price) {
    _pricePerSeat  = price;
    _selectedSeats = 1;
    _couponCode    = null;
    _discount      = 0;
    _couponMessage = null;
    _couponValid   = false;
    _confirmed     = false;
    _error         = null;
    _booking       = null;

    // ✅ Only create Razorpay on mobile — avoids MissingPluginException on web
    if (!kIsWeb) {
      _razorpay?.clear();
      _razorpay = Razorpay();
      _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
      _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR,   _onPaymentError);
    }

    notifyListeners();
  }

  void setSeats(int count) {
    _selectedSeats = count;
    _discount      = 0;
    _couponCode    = null;
    _couponMessage = null;
    _couponValid   = false;
    notifyListeners();
  }

  // ── Coupon ───────────────────────────────────────────────────
  Future<void> applyCoupon(String code) async {
    if (code.isEmpty) return;
    _couponLoading = true; notifyListeners();
    try {
      final res = await _repo.validateCoupon(code: code, amount: baseAmount);
      _discount      = (res['data']['discount'] ?? 0).toDouble();
      _couponCode    = code;
      _couponMessage = res['message'];
      _couponValid   = true;
    } catch (e) {
      _discount      = 0;
      _couponCode    = null;
      _couponValid   = false;
      _couponMessage = _parseError(e);
    } finally {
      _couponLoading = false; notifyListeners();
    }
  }

  void removeCoupon() {
    _couponCode    = null;
    _discount      = 0;
    _couponMessage = null;
    _couponValid   = false;
    notifyListeners();
  }

  // ── Set pending data before payment ──────────────────────────
  void setPendingBookingData({
    required String eventId,
    required int    seats,
    required double amount,
    required double discount,
    required double finalAmount,
    String?         couponCode,
  }) {
    _pendingEventId     = eventId;
    _pendingSeats       = seats;
    _pendingAmount      = amount;
    _pendingDiscount    = discount;
    _pendingFinalAmount = finalAmount;
    _pendingCouponCode  = couponCode;
  }

  // ── Start payment ────────────────────────────────────────────
  Future<void> startPayment(String eventId) async {
    _creatingOrder = true; _error = null; notifyListeners();
    try {
      final res = await _repo.createOrder(
        eventId:    eventId,
        seats:      _selectedSeats,
        couponCode: _couponCode,
      );
      _razorpayOrderId = res['data']['orderId'];
      _razorpayKeyId   = res['data']['keyId'];
      _creatingOrder   = false;
      notifyListeners();

      if (kIsWeb) {
        // ✅ Web: call checkout.js via dart:js (conditional import)
        final result = await razorpayWebCheckout(
          _razorpayKeyId!,
          _razorpayOrderId!,
          (finalAmount * 100).toInt(),
        );
        if (result != null) {
          await _verifyPayment(
            razorpayOrderId:   result['orderId']!,
            razorpayPaymentId: result['paymentId']!,
            razorpaySignature: result['signature']!,
          );
        } else {
          _error = 'Payment cancelled.';
          notifyListeners();
        }
      } else {
        // ✅ Mobile: use razorpay_flutter plugin
        _razorpay!.open({
          'key':         _razorpayKeyId,
          'order_id':    _razorpayOrderId,
          'amount':      (finalAmount * 100).toInt(),
          'currency':    'INR',
          'name':        'EventFi',
          'description': 'Event Ticket Booking',
          'prefill':     {'contact': '', 'email': ''},
          'theme':       {'color': '#FF6B35'},
        });
      }
    } catch (e) {
      _creatingOrder = false;
      _error = _parseError(e);
      notifyListeners();
    }
  }

  // ── Mobile Razorpay callbacks ─────────────────────────────────
  void _onPaymentSuccess(PaymentSuccessResponse response) {
    _verifyPayment(
      razorpayOrderId:   response.orderId   ?? '',
      razorpayPaymentId: response.paymentId ?? '',
      razorpaySignature: response.signature ?? '',
    );
  }

  void _onPaymentError(PaymentFailureResponse response) {
    _error = response.message ?? 'Payment failed. Please try again.';
    notifyListeners();
  }

  // ── Verify with backend ───────────────────────────────────────
  Future<void> _verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    _verifying = true; notifyListeners();
    try {
      final res = await _repo.verifyAndBook(
        razorpayOrderId:   razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
        eventId:           _pendingEventId    ?? '',
        seats:             _pendingSeats      ?? _selectedSeats,
        amount:            _pendingAmount     ?? baseAmount,
        discount:          _pendingDiscount   ?? _discount,
        finalAmount:       _pendingFinalAmount ?? finalAmount,
        couponCode:        _pendingCouponCode ?? _couponCode,
      );
      _booking      = BookingModel.fromJson(res['data']['booking']);
      _pointsEarned = res['data']['pointsEarned'] ?? 0;
      _confirmed    = true;
    } catch (e) {
      _error = _parseError(e);
    } finally {
      _verifying = false; notifyListeners();
    }
  }

  // ── Booking history ───────────────────────────────────────────
  Future<void> loadMyBookings() async {
    _histLoading = true; notifyListeners();
    try {
      _myBookings = await _repo.getMyBookings();
    } catch (e) {
      _error = _parseError(e);
    } finally {
      _histLoading = false; notifyListeners();
    }
  }

  Future<void> cancelBooking(String id) async {
    try {
      await _repo.cancelBooking(id);
      await loadMyBookings();
    } catch (e) {
      _error = _parseError(e); notifyListeners();
    }
  }

  String _parseError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('400')) return 'Payment verification failed.';
    if (msg.contains('404')) return 'Event not found.';
    if (msg.contains('Connection')) return 'Cannot reach server. Check backend.';
    return 'Something went wrong. Try again.';
  }

  @override
  void dispose() {
    _razorpay?.clear(); // safe on mobile, null on web
    super.dispose();
  }
}
