import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';

/// Background message handler — must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM background: ${message.notification?.title}');
}

class FcmService {
  static final _messaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    // Request permissions (iOS + web)
    await _messaging.requestPermission(
      alert:   true,
      badge:   true,
      sound:   true,
    );

    // Background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Foreground handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('FCM foreground: ${message.notification?.title}');
      // TODO Phase 6: show in-app banner using overlay
    });

    // Notification tap handler (app in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('FCM tapped: ${message.data}');
      // TODO: navigate based on message.data['type']
    });

    // Register token with backend
    await _registerToken();

    // Token refresh
    _messaging.onTokenRefresh.listen(_sendTokenToServer);
  }

  static Future<void> _registerToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) await _sendTokenToServer(token);
    } catch (e) {
      debugPrint('FCM token error: $e');
    }
  }

  static Future<void> _sendTokenToServer(String token) async {
    try {
      await ApiClient.instance.dio.post(
        '/notifications/register-token',
        data: {'fcmToken': token},
      );
      debugPrint('FCM token registered with backend');
    } catch (e) {
      debugPrint('FCM token send failed: $e');
    }
  }
}
