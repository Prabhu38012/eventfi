import 'package:dio/dio.dart';
import '../models/points_model.dart';
import '../../../core/network/api_client.dart';

class PointsRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<int> getBalance() async {
    final res = await _dio.get('/points/balance');
    return res.data['data']['balance'] ?? 0;
  }

  Future<List<PointsModel>> getHistory() async {
    final res = await _dio.get('/points/history');
    return (res.data['data']['history'] as List)
        .map((h) => PointsModel.fromJson(h))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getRewards() async {
    final res = await _dio.get('/points/rewards');
    return List<Map<String, dynamic>>.from(res.data['data']['rewards'] ?? []);
  }

  Future<Map<String, dynamic>> redeemReward(String rewardId) async {
    final res = await _dio.post('/points/redeem', data: {'rewardId': rewardId});
    return {
      'message': res.data['message'],
      ...res.data['data'],
    };
  }
}
