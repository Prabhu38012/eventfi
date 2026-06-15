import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'api_endpoints.dart';

// ─────────────────────────────────────────────────────────────
//  ApiClient — sends Firebase ID token on every request
//
//  Firebase.getIdToken() auto-refreshes 5 min before expiry.
//  On 401, force-refreshes and retries once automatically.
// ─────────────────────────────────────────────────────────────

class ApiClient {
  ApiClient._internal();
  static final ApiClient instance = ApiClient._internal();

  late final Dio _dio;
  Dio get dio => _dio;

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl:        ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers:        {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(InterceptorsWrapper(
      // ── Attach Firebase ID token to every request ──────────
      onRequest: (options, handler) async {
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final token = await user.getIdToken(); // auto-refreshes near expiry
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (e) {
          debugPrint('[ApiClient] Could not get Firebase token: $e');
        }
        return handler.next(options);
      },

      // ── On 401: force-refresh token and retry once ─────────
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          debugPrint('[ApiClient] 401 — force refreshing Firebase token...');
          try {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              final fresh = await user.getIdToken(true); // force network refresh
              error.requestOptions.headers['Authorization'] = 'Bearer $fresh';
              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            }
          } catch (e) {
            debugPrint('[ApiClient] Token refresh failed: $e');
          }
        }
        return handler.next(error);
      },

      onResponse: (response, handler) => handler.next(response),
    ));

    // Readable logs in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody:  false,
        responseBody: false,
        logPrint:     (o) => debugPrint('[Dio] $o'),
      ));
    }
  }
}