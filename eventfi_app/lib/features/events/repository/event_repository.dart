import 'package:dio/dio.dart';
import '../models/event_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class EventRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<EventModel>> getEvents({
    String?  category,
    String?  district,
    double?  minPrice,
    double?  maxPrice,
    String?  search,
    int      page  = 1,
    int      limit = 20,
  }) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};

    if (category != null && category != 'all') params['category'] = category;
    if (district != null && district.isNotEmpty) params['district'] = district;
    if (minPrice != null) params['minPrice'] = minPrice;
    if (maxPrice != null) params['maxPrice'] = maxPrice;
    if (search   != null && search.isNotEmpty) params['search'] = search;

    final res = await _dio.get(ApiEndpoints.events, queryParameters: params);
    return (res.data['events'] as List)
        .map((e) => EventModel.fromJson(e))
        .toList();
  }

  Future<List<EventModel>> getTrending() async {
    final res = await _dio.get(ApiEndpoints.trending);
    return (res.data['events'] as List)
        .map((e) => EventModel.fromJson(e))
        .toList();
  }

  Future<EventModel> getEventById(String id) async {
    final res = await _dio.get(ApiEndpoints.eventById(id));
    return EventModel.fromJson(res.data['event']);
  }

  Future<List<String>> getDistricts() async {
    final res = await _dio.get('${ApiEndpoints.events}/districts');
    return List<String>.from(res.data['districts'] ?? []);
  }
}
