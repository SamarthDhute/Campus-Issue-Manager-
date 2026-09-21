package com.smartcampus.issuemanager.service;

import com.smartcampus.issuemanager.dto.*;

import java.util.List;

public interface AnalyticsService {

    ExecutiveMetricsResponse getExecutiveOverview(String timeRange);

    List<CategoryDistributionResponse> getCategoryDistribution(String timeRange);

    List<LocationHotspotResponse> getLocationHotspots(String timeRange);

    List<OperatorLeaderboardResponse> getOperatorLeaderboard(String timeRange);

    List<SlaTrendPointResponse> getSlaTrends(String timeRange);
}
