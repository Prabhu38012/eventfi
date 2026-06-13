import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../events/models/event_model.dart';
import '../../events/repository/event_repository.dart';

class HomeProvider extends ChangeNotifier {
  final _repo = EventRepository();

  List<EventModel> _events   = [];
  List<EventModel> _trending = [];
  List<String>     _districts = [];

  bool    _loading         = false;
  bool    _trendingLoading = false;
  String? _error;

  String  _category   = 'all';
  String  _search     = '';
  String? _district;
  double? _minPrice;
  double? _maxPrice;

  Timer? _debounce;

  // ─── Getters ─────────────────────────────────────────────
  List<EventModel> get events          => _events;
  List<EventModel> get trending        => _trending;
  List<String>     get districts       => _districts;
  bool             get loading         => _loading;
  bool             get trendingLoading => _trendingLoading;
  String?          get error           => _error;
  String           get category        => _category;
  String           get search          => _search;
  String?          get district        => _district;
  double?          get minPrice        => _minPrice;
  double?          get maxPrice        => _maxPrice;
  bool             get hasFilters      => _district != null || _minPrice != null || _maxPrice != null;

  // ─── Init ────────────────────────────────────────────────
  Future<void> init() async {
    await Future.wait([loadEvents(), loadTrending(), loadDistricts()]);
  }

  // ─── Load Events ─────────────────────────────────────────
  Future<void> loadEvents() async {
    _loading = true;
    _error   = null;
    notifyListeners();
    try {
      _events = await _repo.getEvents(
        category: _category,
        district: _district,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        search:   _search,
      );
    } catch (e) {
      _error = 'Failed to load events. Check your connection.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ─── Load Trending ───────────────────────────────────────
  Future<void> loadTrending() async {
    _trendingLoading = true;
    notifyListeners();
    try {
      _trending = await _repo.getTrending();
    } catch (_) {}
    _trendingLoading = false;
    notifyListeners();
  }

  // ─── Load Districts for filter ───────────────────────────
  Future<void> loadDistricts() async {
    try {
      _districts = await _repo.getDistricts();
      notifyListeners();
    } catch (_) {}
  }

  // ─── Category Selection ──────────────────────────────────
  void setCategory(String cat) {
    if (_category == cat) return;
    _category = cat;
    loadEvents();
  }

  // ─── Debounced Search ────────────────────────────────────
  void setSearch(String q) {
    _search = q;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), loadEvents);
    notifyListeners();
  }

  // ─── Apply Filters from bottom sheet ────────────────────
  void applyFilters({String? district, double? minPrice, double? maxPrice}) {
    _district = district;
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    loadEvents();
  }

  // ─── Clear Filters ───────────────────────────────────────
  void clearFilters() {
    _district = null;
    _minPrice = null;
    _maxPrice = null;
    loadEvents();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
