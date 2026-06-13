import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_endpoints.dart';

/// EventFi API Client — Singleton Dio instance
/// Automatically attaches JWT token to every request.
class ApiClient {
  ApiClient._();
  static final ApiClient _instance = ApiClient._();
  static ApiClient get instance => _instance;

  late Dio _dio;
  late Dio _aiDio;

  /// Call this once in main.dart before runApp()
  void init() {
    _dio = Dio(BaseOptions(
      baseUrl:        ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers:        {'Content-Type': 'application/json'},
    ));

    _aiDio = Dio(BaseOptions(
      baseUrl:        ApiEndpoints.aiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers:        {'Content-Type': 'application/json'},
    ));

    // JWT Auth Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // 401 = token expired → handled by auth_provider
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio   => _dio;
  Dio get aiDio => _aiDio;
}
