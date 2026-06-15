import 'package:flutter/foundation.dart';
import '../models/points_model.dart';
import '../repository/points_repository.dart';

class PointsProvider extends ChangeNotifier {
  final _repo = PointsRepository();

  int    _balance  = 0;
  List<PointsModel>          _history = [];
  List<Map<String, dynamic>> _rewards = [];

  bool    _loading   = false;
  bool    _redeeming = false;
  String? _error;
  String? _redeemMessage;
  String? _earnedCoupon;

  // ─── Getters ───────────────────────────────────────────────
  int    get balance      => _balance;
  List<PointsModel>          get history  => _history;
  List<Map<String, dynamic>> get rewards  => _rewards;
  bool    get loading     => _loading;
  bool    get redeeming   => _redeeming;
  String? get error       => _error;
  String? get redeemMsg   => _redeemMessage;
  String? get earnedCoupon => _earnedCoupon;

  // ─── Tier System ────────────────────────────────────────────
  String get tier {
    if (_balance >= 500) return 'Platinum';
    if (_balance >= 200) return 'Gold';
    if (_balance >= 50)  return 'Silver';
    return 'Bronze';
  }

  String get tierEmoji {
    switch (tier) {
      case 'Platinum': return '💎';
      case 'Gold':     return '🥇';
      case 'Silver':   return '🥈';
      default:         return '🥉';
    }
  }

  /// Points needed to reach NEXT tier
  int get pointsToNextTier {
    if (_balance >= 500) return 0;
    if (_balance >= 200) return 500 - _balance;
    if (_balance >= 50)  return 200 - _balance;
    return 50 - _balance;
  }

  /// Progress 0.0 → 1.0 within current tier
  double get tierProgress {
    if (_balance >= 500) return 1.0;
    if (_balance >= 200) return (_balance - 200) / (500 - 200);
    if (_balance >= 50)  return (_balance - 50)  / (200 - 50);
    return _balance / 50;
  }

  // ─── Load ────────────────────────────────────────────────────
  Future<void> init() async {
    _loading = true; notifyListeners();
    try {
      await Future.wait([loadBalance(), loadHistory(), loadRewards()]);
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<void> loadBalance() async {
    try { _balance = await _repo.getBalance(); notifyListeners(); }
    catch (_) {}
  }

  Future<void> loadHistory() async {
    try { _history = await _repo.getHistory(); notifyListeners(); }
    catch (_) {}
  }

  Future<void> loadRewards() async {
    try { _rewards = await _repo.getRewards(); notifyListeners(); }
    catch (_) {}
  }

  // ─── Redeem ──────────────────────────────────────────────────
  Future<bool> redeemReward(String rewardId) async {
    _redeeming     = true;
    _redeemMessage = null;
    _earnedCoupon  = null;
    notifyListeners();
    try {
      final res       = await _repo.redeemReward(rewardId);
      _balance        = res['remainingPoints'] ?? _balance;
      _earnedCoupon   = res['couponCode'];
      _redeemMessage  = res['message'] ?? 'Reward redeemed!';
      await loadHistory();
      return true;
    } catch (e) {
      _redeemMessage = e.toString().contains('400')
          ? 'Not enough points.'
          : 'Redemption failed. Try again.';
      return false;
    } finally {
      _redeeming = false; notifyListeners();
    }
  }

  void clearRedeemState() {
    _redeemMessage = null;
    _earnedCoupon  = null;
    notifyListeners();
  }

  /// Call this after a booking is confirmed to refresh balance
  void refreshAfterBooking() {
    loadBalance();
    loadHistory();
  }
}
