import 'package:flutter/material.dart';
import '../data/models/analytics_models.dart';
import '../data/repositories/analytics_repository.dart';

class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsRepository _repository;

  String _selectedTimeRange = '30d'; // '7d', '30d', '90d', 'all'
  bool _isLoading = false;
  String? _errorMessage;

  ExecutiveMetricsModel? _overview;
  List<CategoryDistributionModel> _categories = [];
  List<LocationHotspotModel> _hotspots = [];
  List<OperatorLeaderboardModel> _leaderboard = [];
  List<SlaTrendPointModel> _slaTrends = [];

  AnalyticsProvider({AnalyticsRepository? repository})
      : _repository = repository ?? AnalyticsRepository();

  String get selectedTimeRange => _selectedTimeRange;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ExecutiveMetricsModel? get overview => _overview;
  List<CategoryDistributionModel> get categories => _categories;
  List<LocationHotspotModel> get hotspots => _hotspots;
  List<OperatorLeaderboardModel> get leaderboard => _leaderboard;
  List<SlaTrendPointModel> get slaTrends => _slaTrends;

  Future<void> setTimeRange(String timeRange) async {
    if (_selectedTimeRange == timeRange) return;
    _selectedTimeRange = timeRange;
    notifyListeners();
    await loadAllAnalytics();
  }

  Future<void> loadAllAnalytics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getExecutiveOverview(timeRange: _selectedTimeRange),
        _repository.getCategoryDistribution(timeRange: _selectedTimeRange),
        _repository.getLocationHotspots(timeRange: _selectedTimeRange),
        _repository.getOperatorLeaderboard(timeRange: _selectedTimeRange),
        _repository.getSlaTrends(timeRange: _selectedTimeRange),
      ]);

      _overview = results[0] as ExecutiveMetricsModel;
      _categories = results[1] as List<CategoryDistributionModel>;
      _hotspots = results[2] as List<LocationHotspotModel>;
      _leaderboard = results[3] as List<OperatorLeaderboardModel>;
      _slaTrends = results[4] as List<SlaTrendPointModel>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
