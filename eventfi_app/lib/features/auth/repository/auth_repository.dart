import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class AuthRepository {
  final _auth        = FirebaseAuth.instance;
  // On web, google_sign_in_web reads the client ID from the meta tag:
  // <meta name="google-signin-client_id" content="YOUR_CLIENT_ID.apps.googleusercontent.com">
  // in web/index.html — so we do not pass clientId here.
  final _googleSignIn = GoogleSignIn();

  // ─── Email / Password ────────────────────────────────────
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.updateDisplayName(name);
    return cred;
  }

  Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ─── Google ──────────────────────────────────────────────
  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken:     googleAuth.idToken,
    );
    return await _auth.signInWithCredential(credential);
  }

  // ─── Phone OTP ───────────────────────────────────────────
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error)          onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential cred) async {
        // Auto-verification on Android
        await _auth.signInWithCredential(cred);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'Verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode:        otp,
    );
    return await _auth.signInWithCredential(credential);
  }

  // ─── Backend Sync ────────────────────────────────────────
  /// After any Firebase auth → call backend to get JWT + user from MongoDB
  Future<Map<String, dynamic>> syncWithBackend(User firebaseUser) async {
    final idToken = await firebaseUser.getIdToken(true);
    final response = await ApiClient.instance.dio.post(
      ApiEndpoints.firebaseSync,
      data: {'idToken': idToken},
    );
    return response.data as Map<String, dynamic>;
  }

  // ─── Sign Out ────────────────────────────────────────────
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  User?         get currentUser       => _auth.currentUser;
  Stream<User?> get authStateChanges  => _auth.authStateChanges();
}
