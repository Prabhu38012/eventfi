import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../repository/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final _repo = AuthRepository();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String?    _error;
  String?    _verificationId;

  AuthStatus  get status         => _status;
  UserModel?  get user           => _user;
  String?     get error          => _error;
  bool        get isAuthenticated => _status == AuthStatus.authenticated;
  bool        get isAdmin         => _user?.role == 'admin';

  /// Call once inside app.dart — listens to Firebase auth state continuously
  void init() {
    _repo.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        await _syncUser(firebaseUser);
      } else {
        _status = AuthStatus.unauthenticated;
        _user   = null;
        notifyListeners();
      }
    });
  }

  Future<void> _syncUser(User firebaseUser) async {
    try {
      final result = await _repo.syncWithBackend(firebaseUser);
      final prefs  = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', result['data']['token'] as String);
      _user   = UserModel.fromJson(result['data']['user'] as Map<String, dynamic>);
      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e, stack) {
      print('❌ [AuthProvider] Sync User error: $e\n$stack');
      _status = AuthStatus.unauthenticated;
      _setError('Sync failed: $e');
      notifyListeners();
    }
  }

  // ─── Email Sign Up ───────────────────────────────────────
  Future<bool> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      await _repo.signUpWithEmail(name: name, email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      print('❌ [AuthProvider] Firebase Auth Exception during signup: ${e.code} - ${e.message}');
      _setError(_firebaseMsg(e.code));
      return false;
    } catch (e, stack) {
      print('❌ [AuthProvider] Generic Exception during signup: $e\n$stack');
      _setError('Signup failed: $e');
      return false;
    }
  }

  // ─── Email Login ─────────────────────────────────────────
  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      await _repo.loginWithEmail(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_firebaseMsg(e.code));
      return false;
    }
  }

  // ─── Google ──────────────────────────────────────────────
  Future<bool> signInWithGoogle() async {
    _setLoading();
    try {
      final cred = await _repo.signInWithGoogle();
      if (cred == null) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
      return true;
    } catch (_) {
      _setError('Google sign-in failed. Try again.');
      return false;
    }
  }

  // ─── Phone — Send OTP ────────────────────────────────────
  Future<void> sendOtp(String phoneNumber) async {
    _setLoading();
    await _repo.sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: (vId) {
        _verificationId = vId;
        _status         = AuthStatus.initial;
        notifyListeners();
      },
      onError: (err) => _setError(err),
    );
  }

  // ─── Phone — Verify OTP ──────────────────────────────────
  Future<bool> verifyOtp(String otp) async {
    if (_verificationId == null) {
      _setError('Session expired. Resend OTP.');
      return false;
    }
    _setLoading();
    try {
      await _repo.verifyOtp(verificationId: _verificationId!, otp: otp);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_firebaseMsg(e.code));
      return false;
    }
  }

  // ─── Forgot Password ─────────────────────────────────────
  Future<bool> sendPasswordReset(String email) async {
    _setLoading();
    try {
      await _repo.sendPasswordReset(email);
      _status = AuthStatus.initial;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_firebaseMsg(e.code));
      return false;
    }
  }

  // ─── Sign Out ────────────────────────────────────────────
  Future<void> signOut() async {
    await _repo.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _user   = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ─── Helpers ─────────────────────────────────────────────
  void _setLoading() {
    _error  = null;
    _status = AuthStatus.loading;
    notifyListeners();
  }

  void _setError(String msg) {
    _error  = msg;
    _status = AuthStatus.error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _firebaseMsg(String code) {
    switch (code) {
      case 'user-not-found':            return 'No account found with this email.';
      case 'wrong-password':            return 'Incorrect password. Try again.';
      case 'email-already-in-use':      return 'This email is already registered.';
      case 'weak-password':             return 'Password must be at least 6 characters.';
      case 'invalid-email':             return 'Please enter a valid email address.';
      case 'too-many-requests':         return 'Too many attempts. Try again later.';
      case 'invalid-verification-code': return 'Incorrect OTP. Please try again.';
      case 'session-expired':           return 'OTP expired. Please resend.';
      default:                          return 'Something went wrong. Try again.';
    }
  }
}
