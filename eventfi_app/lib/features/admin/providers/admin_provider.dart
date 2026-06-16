import 'package:flutter/foundation.dart';
import '../models/admin_stats_model.dart';
import '../repository/admin_repository.dart';

class AdminProvider extends ChangeNotifier {
  final _repo = AdminRepository();

  AdminStats? _stats;
  List<Map<String, dynamic>> _events   = [];
  List<Map<String, dynamic>> _bookings = [];
  List<Map<String, dynamic>> _coupons  = [];
  int     _totalBookings = 0;

  bool    _loading   = false;
  bool    _saving    = false;
  String? _error;
  String? _success;

  // Scan state
  Map<String, dynamic>? _scannedBooking;
  bool _scanLoading = false;
  bool _scanCheckedIn = false;

  AdminStats? get stats    => _stats;
  List<Map<String, dynamic>> get events   => _events;
  List<Map<String, dynamic>> get bookings => _bookings;
  List<Map<String, dynamic>> get coupons  => _coupons;
  int     get totalBookings  => _totalBookings;
  bool    get loading        => _loading;
  bool    get saving         => _saving;
  String? get error          => _error;
  String? get success        => _success;
  Map<String, dynamic>? get scannedBooking => _scannedBooking;
  bool    get scanLoading    => _scanLoading;
  bool    get scanCheckedIn  => _scanCheckedIn;

  // ── Dashboard ─────────────────────────────────────────────
  Future<void> loadStats() async {
    _loading = true; notifyListeners();
    try { _stats = await _repo.getStats(); }
    catch (e) { _error = _parseError(e); }
    finally { _loading = false; notifyListeners(); }
  }

  // ── Events ────────────────────────────────────────────────
  Future<void> loadEvents() async {
    _loading = true; notifyListeners();
    try { _events = await _repo.getEvents(); }
    catch (e) { _error = _parseError(e); }
    finally { _loading = false; notifyListeners(); }
  }

  Future<bool> createEvent(Map<String, dynamic> data) async {
    _saving = true; _error = null; notifyListeners();
    try {
      await _repo.createEvent(data);
      _success = 'Event created!';
      await loadEvents();
      return true;
    } catch (e) { _error = _parseError(e); return false; }
    finally { _saving = false; notifyListeners(); }
  }

  Future<bool> updateEvent(String id, Map<String, dynamic> data) async {
    _saving = true; _error = null; notifyListeners();
    try {
      await _repo.updateEvent(id, data);
      _success = 'Event updated!';
      await loadEvents();
      return true;
    } catch (e) { _error = _parseError(e); return false; }
    finally { _saving = false; notifyListeners(); }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _repo.deleteEvent(id);
      _events.removeWhere((e) => e['_id'] == id);
      _success = 'Event deleted';
      notifyListeners();
    } catch (e) { _error = _parseError(e); notifyListeners(); }
  }

  // ── Bookings ──────────────────────────────────────────────
  Future<void> loadBookings({String? status}) async {
    _loading = true; notifyListeners();
    try {
      final res   = await _repo.getBookings(status: status);
      _bookings   = res['bookings'] as List<Map<String, dynamic>>;
      _totalBookings = res['total'] as int;
    } catch (e) { _error = _parseError(e); }
    finally { _loading = false; notifyListeners(); }
  }

  Future<void> scanQr(String bookingId) async {
    _scanLoading = true; _scannedBooking = null;
    _scanCheckedIn = false; _error = null;
    notifyListeners();
    try {
      _scannedBooking = await _repo.scanBooking(bookingId.trim().toUpperCase());
    } catch (e) { _error = _parseError(e); }
    finally { _scanLoading = false; notifyListeners(); }
  }

  Future<void> confirmAttendance(String bookingId) async {
    _saving = true; notifyListeners();
    try {
      await _repo.markAttended(bookingId);
      _scanCheckedIn = true;
      _success = '✅ Checked in!';
    } catch (e) { _error = _parseError(e); }
    finally { _saving = false; notifyListeners(); }
  }

  void clearScan() {
    _scannedBooking = null;
    _scanCheckedIn  = false;
    _error          = null;
    notifyListeners();
  }

  // ── Coupons ───────────────────────────────────────────────
  Future<void> loadCoupons() async {
    _loading = true; notifyListeners();
    try { _coupons = await _repo.getCoupons(); }
    catch (e) { _error = _parseError(e); }
    finally { _loading = false; notifyListeners(); }
  }

  Future<bool> createCoupon(Map<String, dynamic> data) async {
    _saving = true; _error = null; notifyListeners();
    try {
      await _repo.createCoupon(data);
      _success = 'Coupon created!';
      await loadCoupons();
      return true;
    } catch (e) { _error = _parseError(e); return false; }
    finally { _saving = false; notifyListeners(); }
  }

  Future<void> toggleCoupon(String id) async {
    try {
      await _repo.toggleCoupon(id);
      await loadCoupons();
    } catch (e) { _error = _parseError(e); notifyListeners(); }
  }

  Future<void> deleteCoupon(String id) async {
    try {
      await _repo.deleteCoupon(id);
      _coupons.removeWhere((c) => c['_id'] == id);
      notifyListeners();
    } catch (e) { _error = _parseError(e); notifyListeners(); }
  }

  void clearMessages() {
    _error = null; _success = null; notifyListeners();
  }

  String _parseError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('403')) return 'Admin access required';
    if (msg.contains('404')) return 'Not found';
    if (msg.contains('Connection')) return 'Cannot reach server';
    return 'Something went wrong';
  }
}
