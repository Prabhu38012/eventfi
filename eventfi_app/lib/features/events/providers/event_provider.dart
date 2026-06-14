import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import '../repository/event_repository.dart';

class EventProvider extends ChangeNotifier {
  final _repo = EventRepository();

  EventModel? _event;
  bool        _loading    = false;
  String?     _error;
  bool        _inWishlist = false;

  EventModel? get event      => _event;
  bool        get loading    => _loading;
  String?     get error      => _error;
  bool        get inWishlist => _inWishlist;

  Future<void> loadEvent(String id) async {
    _loading = true;
    _error   = null;
    notifyListeners();
    try {
      _event = await _repo.getEventById(id);
    } catch (e) {
      _error = 'Failed to load event details. Check your connection.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void toggleWishlist() {
    _inWishlist = !_inWishlist;
    notifyListeners();
    // Phase 6: connect to backend wishlist API
  }

  void clear() {
    _event      = null;
    _loading    = false;
    _error      = null;
    _inWishlist = false;
  }
}
