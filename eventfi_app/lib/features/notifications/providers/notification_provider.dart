import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../repository/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final _repo = NotificationRepository();

  List<NotificationModel> _notifications = [];
  int     _unreadCount = 0;
  bool    _loading     = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  int     get unreadCount => _unreadCount;
  bool    get loading     => _loading;
  String? get error       => _error;

  Future<void> loadNotifications() async {
    _loading = true; notifyListeners();
    try {
      final data    = await _repo.getNotifications();
      _notifications = data['notifications'] as List<NotificationModel>;
      _unreadCount   = data['unreadCount']   as int;
    } catch (_) {}
    _loading = false; notifyListeners();
  }

  Future<void> markRead(String id) async {
    try {
      await _repo.markRead(id);
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx != -1) {
        _notifications[idx] = NotificationModel(
          id:        _notifications[idx].id,
          title:     _notifications[idx].title,
          body:      _notifications[idx].body,
          type:      _notifications[idx].type,
          isRead:    true,
          createdAt: _notifications[idx].createdAt,
          data:      _notifications[idx].data,
        );
        _unreadCount = (_unreadCount - 1).clamp(0, 99);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    try {
      await _repo.markAllRead();
      _notifications = _notifications.map((n) => NotificationModel(
        id: n.id, title: n.title, body: n.body,
        type: n.type, isRead: true, createdAt: n.createdAt, data: n.data,
      )).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (_) {}
  }
}
