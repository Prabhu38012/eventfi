import 'package:flutter/foundation.dart';
import '../repository/wishlist_repository.dart';
import '../../events/models/event_model.dart';

class WishlistProvider extends ChangeNotifier {
  final _repo = WishlistRepository();

  List<EventModel> _events     = [];
  Set<String>      _ids        = {};
  bool             _loading    = false;
  String?          _error;

  List<EventModel> get events  => _events;
  bool             get loading => _loading;
  bool isSaved(String id)      => _ids.contains(id);
  int  get count               => _events.length;

  Future<void> init() async {
    _loading = true; notifyListeners();
    try {
      _ids    = (await _repo.getWishlistIds()).toSet();
      _events = await _repo.getWishlist();
    } catch (_) {}
    _loading = false; notifyListeners();
  }

  Future<void> toggle(String eventId) async {
    // Optimistic update
    final wasAdded = _ids.contains(eventId);
    if (wasAdded) {
      _ids.remove(eventId);
      _events.removeWhere((e) => e.id == eventId);
    } else {
      _ids.add(eventId);
    }
    notifyListeners();

    try {
      final added = await _repo.toggle(eventId);
      if (added && !_ids.contains(eventId)) {
        _ids.add(eventId);
      } else if (!added) {
        _ids.remove(eventId);
        _events.removeWhere((e) => e.id == eventId);
      }
      // Refresh events list
      if (added) _events = await _repo.getWishlist();
    } catch (_) {
      // Revert on error
      if (wasAdded) { _ids.add(eventId); }
      else          { _ids.remove(eventId); }
    }
    notifyListeners();
  }
}
