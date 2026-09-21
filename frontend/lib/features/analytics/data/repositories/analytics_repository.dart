import 'package:smart_campus_issue_manager/core/network/api_client.dart';
import '../models/analytics_models.dart';

class AnalyticsRepository {
  final ApiClient _apiClient;

  AnalyticsRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<ExecutiveMetricsModel> getExecutiveOverview({String timeRange = '30d'}) async {
    final response = await _apiClient.get('/analytics/overview?timeRange=$timeRange');
    return ExecutiveMetricsModel.fromJson(response as Map<String, dynamic>);
  }

  Future<List<CategoryDistributionModel>> getCategoryDistribution({String timeRange = '30d'}) async {
    final response = await _apiClient.get('/analytics/categories?timeRange=$timeRange');
    if (response is List) {
      return response.map((e) => CategoryDistributionModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<LocationHotspotModel>> getLocationHotspots({String timeRange = '30d'}) async {
    final response = await _apiClient.get('/analytics/hotspots?timeRange=$timeRange');
    if (response is List) {
      return response.map((e) => LocationHotspotModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<OperatorLeaderboardModel>> getOperatorLeaderboard({String timeRange = '30d'}) async {
    final response = await _apiClient.get('/analytics/leaderboard?timeRange=$timeRange');
    if (response is List) {
      return response.map((e) => OperatorLeaderboardModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<SlaTrendPointModel>> getSlaTrends({String timeRange = '30d'}) async {
    final response = await _apiClient.get('/analytics/sla-trends?timeRange=$timeRange');
    if (response is List) {
      return response.map((e) => SlaTrendPointModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
