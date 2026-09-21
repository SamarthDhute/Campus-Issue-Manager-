class ExecutiveMetricsModel {
  final int totalIssuesCount;
  final int activeIssuesCount;
  final int resolvedIssuesCount;
  final int breachedIssuesCount;
  final int pendingApprovalCount;
  final double slaComplianceRate;
  final double averageResolutionHours;
  final double averageResponseHours;
  final double averageCsatRating;
  final int totalFeedbacksCount;
  final String resolutionEfficiencyTrend;
  final String timeRange;

  ExecutiveMetricsModel({
    required this.totalIssuesCount,
    required this.activeIssuesCount,
    required this.resolvedIssuesCount,
    required this.breachedIssuesCount,
    required this.pendingApprovalCount,
    required this.slaComplianceRate,
    required this.averageResolutionHours,
    required this.averageResponseHours,
    required this.averageCsatRating,
    required this.totalFeedbacksCount,
    required this.resolutionEfficiencyTrend,
    required this.timeRange,
  });

  factory ExecutiveMetricsModel.fromJson(Map<String, dynamic> json) {
    return ExecutiveMetricsModel(
      totalIssuesCount: (json['totalIssuesCount'] as num?)?.toInt() ?? 0,
      activeIssuesCount: (json['activeIssuesCount'] as num?)?.toInt() ?? 0,
      resolvedIssuesCount: (json['resolvedIssuesCount'] as num?)?.toInt() ?? 0,
      breachedIssuesCount: (json['breachedIssuesCount'] as num?)?.toInt() ?? 0,
      pendingApprovalCount: (json['pendingApprovalCount'] as num?)?.toInt() ?? 0,
      slaComplianceRate: (json['slaComplianceRate'] as num?)?.toDouble() ?? 95.0,
      averageResolutionHours: (json['averageResolutionHours'] as num?)?.toDouble() ?? 4.0,
      averageResponseHours: (json['averageResponseHours'] as num?)?.toDouble() ?? 1.0,
      averageCsatRating: (json['averageCsatRating'] as num?)?.toDouble() ?? 4.8,
      totalFeedbacksCount: (json['totalFeedbacksCount'] as num?)?.toInt() ?? 0,
      resolutionEfficiencyTrend: json['resolutionEfficiencyTrend'] as String? ?? '+5.2% vs last cycle',
      timeRange: json['timeRange'] as String? ?? '30d',
    );
  }
}

class CategoryDistributionModel {
  final String? categoryId;
  final String categoryName;
  final int totalIssuesCount;
  final int activeCount;
  final int resolvedCount;
  final double percentageShare;
  final String colorHex;

  CategoryDistributionModel({
    this.categoryId,
    required this.categoryName,
    required this.totalIssuesCount,
    required this.activeCount,
    required this.resolvedCount,
    required this.percentageShare,
    required this.colorHex,
  });

  factory CategoryDistributionModel.fromJson(Map<String, dynamic> json) {
    return CategoryDistributionModel(
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String? ?? 'General',
      totalIssuesCount: (json['totalIssuesCount'] as num?)?.toInt() ?? 0,
      activeCount: (json['activeCount'] as num?)?.toInt() ?? 0,
      resolvedCount: (json['resolvedCount'] as num?)?.toInt() ?? 0,
      percentageShare: (json['percentageShare'] as num?)?.toDouble() ?? 0.0,
      colorHex: json['colorHex'] as String? ?? '#4F46E5',
    );
  }
}

class LocationHotspotModel {
  final String locationName;
  final String buildingZone;
  final int totalIncidentCount;
  final int activeIncidentCount;
  final int resolvedIncidentCount;
  final String primaryCategory;
  final String riskLevel;
  final double recurringRate;

  LocationHotspotModel({
    required this.locationName,
    required this.buildingZone,
    required this.totalIncidentCount,
    required this.activeIncidentCount,
    required this.resolvedIncidentCount,
    required this.primaryCategory,
    required this.riskLevel,
    required this.recurringRate,
  });

  factory LocationHotspotModel.fromJson(Map<String, dynamic> json) {
    return LocationHotspotModel(
      locationName: json['locationName'] as String? ?? '',
      buildingZone: json['buildingZone'] as String? ?? 'Campus Complex',
      totalIncidentCount: (json['totalIncidentCount'] as num?)?.toInt() ?? 0,
      activeIncidentCount: (json['activeIncidentCount'] as num?)?.toInt() ?? 0,
      resolvedIncidentCount: (json['resolvedIncidentCount'] as num?)?.toInt() ?? 0,
      primaryCategory: json['primaryCategory'] as String? ?? 'General',
      riskLevel: json['riskLevel'] as String? ?? 'LOW',
      recurringRate: (json['recurringRate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class OperatorLeaderboardModel {
  final String? operatorId;
  final String name;
  final String email;
  final String teamName;
  final int totalAssignedCount;
  final int resolvedCount;
  final int activeWorkloadCount;
  final double averageResolutionHours;
  final double csatRating;
  final double slaComplianceRate;
  final String efficiencyBadge;

  OperatorLeaderboardModel({
    this.operatorId,
    required this.name,
    required this.email,
    required this.teamName,
    required this.totalAssignedCount,
    required this.resolvedCount,
    required this.activeWorkloadCount,
    required this.averageResolutionHours,
    required this.csatRating,
    required this.slaComplianceRate,
    required this.efficiencyBadge,
  });

  factory OperatorLeaderboardModel.fromJson(Map<String, dynamic> json) {
    return OperatorLeaderboardModel(
      operatorId: json['operatorId'] as String?,
      name: json['name'] as String? ?? 'Staff Member',
      email: json['email'] as String? ?? '',
      teamName: json['teamName'] as String? ?? 'Facilities & Ops',
      totalAssignedCount: (json['totalAssignedCount'] as num?)?.toInt() ?? 0,
      resolvedCount: (json['resolvedCount'] as num?)?.toInt() ?? 0,
      activeWorkloadCount: (json['activeWorkloadCount'] as num?)?.toInt() ?? 0,
      averageResolutionHours: (json['averageResolutionHours'] as num?)?.toDouble() ?? 3.5,
      csatRating: (json['csatRating'] as num?)?.toDouble() ?? 4.8,
      slaComplianceRate: (json['slaComplianceRate'] as num?)?.toDouble() ?? 98.0,
      efficiencyBadge: json['efficiencyBadge'] as String? ?? 'Top Performer',
    );
  }
}

class SlaTrendPointModel {
  final String dateLabel;
  final int totalEvaluated;
  final int compliantCount;
  final int breachedCount;
  final double compliancePercentage;

  SlaTrendPointModel({
    required this.dateLabel,
    required this.totalEvaluated,
    required this.compliantCount,
    required this.breachedCount,
    required this.compliancePercentage,
  });

  factory SlaTrendPointModel.fromJson(Map<String, dynamic> json) {
    return SlaTrendPointModel(
      dateLabel: json['dateLabel'] as String? ?? '',
      totalEvaluated: (json['totalEvaluated'] as num?)?.toInt() ?? 0,
      compliantCount: (json['compliantCount'] as num?)?.toInt() ?? 0,
      breachedCount: (json['breachedCount'] as num?)?.toInt() ?? 0,
      compliancePercentage: (json['compliancePercentage'] as num?)?.toDouble() ?? 100.0,
    );
  }
}
