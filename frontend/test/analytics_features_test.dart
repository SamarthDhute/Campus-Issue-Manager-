import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus_issue_manager/features/analytics/data/models/analytics_models.dart';
import 'package:smart_campus_issue_manager/features/analytics/presentation/widgets/category_breakdown_widget.dart';
import 'package:smart_campus_issue_manager/features/analytics/presentation/widgets/executive_kpi_card.dart';
import 'package:smart_campus_issue_manager/features/analytics/presentation/widgets/location_hotspots_widget.dart';
import 'package:smart_campus_issue_manager/features/analytics/presentation/widgets/operator_leaderboard_widget.dart';
import 'package:smart_campus_issue_manager/features/analytics/presentation/widgets/time_range_filter_bar.dart';

void main() {
  group('Analytics Models JSON Parsing Test Suite', () {
    test('ExecutiveMetricsModel parses correctly from json', () {
      final json = {
        'totalIssuesCount': 42,
        'activeIssuesCount': 10,
        'resolvedIssuesCount': 32,
        'breachedIssuesCount': 2,
        'pendingApprovalCount': 3,
        'slaComplianceRate': 95.2,
        'averageResolutionHours': 3.4,
        'averageResponseHours': 0.8,
        'averageCsatRating': 4.85,
        'totalFeedbacksCount': 28,
        'resolutionEfficiencyTrend': '+12% faster',
        'timeRange': '30d'
      };

      final model = ExecutiveMetricsModel.fromJson(json);

      expect(model.totalIssuesCount, 42);
      expect(model.activeIssuesCount, 10);
      expect(model.resolvedIssuesCount, 32);
      expect(model.breachedIssuesCount, 2);
      expect(model.slaComplianceRate, 95.2);
      expect(model.averageResolutionHours, 3.4);
      expect(model.averageCsatRating, 4.85);
      expect(model.resolutionEfficiencyTrend, '+12% faster');
    });

    test('LocationHotspotModel and OperatorLeaderboardModel parse correctly', () {
      final hotspotJson = {
        'locationName': 'Hostel Block B - Floor 2',
        'buildingZone': 'Hostel Complex',
        'totalIncidentCount': 14,
        'activeIncidentCount': 3,
        'resolvedIncidentCount': 11,
        'primaryCategory': 'Plumbing',
        'riskLevel': 'HIGH',
        'recurringRate': 57.1
      };

      final hotspot = LocationHotspotModel.fromJson(hotspotJson);
      expect(hotspot.locationName, 'Hostel Block B - Floor 2');
      expect(hotspot.riskLevel, 'HIGH');
      expect(hotspot.recurringRate, 57.1);

      final opJson = {
        'name': 'Priya Patel',
        'email': 'operator@smartcampus.edu',
        'teamName': 'Electrical & Facilities',
        'totalAssignedCount': 25,
        'resolvedCount': 22,
        'activeWorkloadCount': 3,
        'averageResolutionHours': 2.1,
        'csatRating': 4.9,
        'slaComplianceRate': 96.0,
        'efficiencyBadge': 'Speed Champion'
      };

      final op = OperatorLeaderboardModel.fromJson(opJson);
      expect(op.name, 'Priya Patel');
      expect(op.resolvedCount, 22);
      expect(op.efficiencyBadge, 'Speed Champion');
    });

    test('CategoryDistributionModel parses properly', () {
      final catJson = {
        'categoryName': 'Electrical',
        'totalIssuesCount': 18,
        'activeCount': 4,
        'resolvedCount': 14,
        'percentageShare': 42.8,
        'colorHex': '#F59E0B'
      };

      final cat = CategoryDistributionModel.fromJson(catJson);
      expect(cat.categoryName, 'Electrical');
      expect(cat.percentageShare, 42.8);
      expect(cat.colorHex, '#F59E0B');
    });
  });

  group('Analytics Presentation Widgets Test Suite', () {
    testWidgets('TimeRangeFilterBar renders options and reacts to selection', (tester) async {
      String selected = '30d';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeRangeFilterBar(
              selectedRange: selected,
              onSelected: (val) => selected = val,
            ),
          ),
        ),
      );

      expect(find.text('Last 30 Days'), findsOneWidget);
      expect(find.text('Last 7 Days'), findsOneWidget);
      expect(find.text('Last Quarter'), findsOneWidget);
      expect(find.text('All Time'), findsOneWidget);

      await tester.tap(find.text('Last 7 Days'));
      await tester.pump();
      expect(selected, '7d');
    });

    testWidgets('ExecutiveKpiCard renders metric values', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExecutiveKpiCard(
              title: 'Mean Time to Resolve',
              value: '3.5 hrs',
              subtitle: 'Top 5% efficiency',
              icon: Icons.timer,
              accentColor: Colors.blue,
              badgeText: 'Optimal',
            ),
          ),
        ),
      );

      expect(find.text('Mean Time to Resolve'), findsOneWidget);
      expect(find.text('3.5 hrs'), findsOneWidget);
      expect(find.text('Top 5% efficiency'), findsOneWidget);
      expect(find.text('Optimal'), findsOneWidget);
    });

    testWidgets('LocationHotspotsWidget renders hotspots list items', (tester) async {
      final testHotspots = [
        LocationHotspotModel(
          locationName: 'Library Main Hall',
          buildingZone: 'Academic Core',
          totalIncidentCount: 8,
          activeIncidentCount: 2,
          resolvedIncidentCount: 6,
          primaryCategory: 'HVAC / AC',
          riskLevel: 'MEDIUM',
          recurringRate: 35.0,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationHotspotsWidget(hotspots: testHotspots),
          ),
        ),
      );

      expect(find.text('Campus Hotspots & Failure Density'), findsOneWidget);
      expect(find.text('Library Main Hall'), findsOneWidget);
      expect(find.text('MEDIUM'), findsOneWidget);
      expect(find.text('8 incidents'), findsOneWidget);
    });

    testWidgets('CategoryBreakdownWidget and OperatorLeaderboardWidget render correctly', (tester) async {
      final categories = [
        CategoryDistributionModel(
          categoryName: 'Network & WiFi',
          totalIssuesCount: 12,
          activeCount: 2,
          resolvedCount: 10,
          percentageShare: 30.0,
          colorHex: '#3B82F6',
        ),
      ];

      final leaderboard = [
        OperatorLeaderboardModel(
          name: 'Vikram Singh',
          email: 'vikram@smartcampus.edu',
          teamName: 'IT & Infrastructure',
          totalAssignedCount: 15,
          resolvedCount: 14,
          activeWorkloadCount: 1,
          averageResolutionHours: 1.8,
          csatRating: 4.95,
          slaComplianceRate: 98.0,
          efficiencyBadge: 'Top Performer',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  CategoryBreakdownWidget(categories: categories),
                  OperatorLeaderboardWidget(leaderboard: leaderboard),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Category Incident Distribution'), findsOneWidget);
      expect(find.text('Network & WiFi'), findsOneWidget);
      expect(find.text('12 (30.0%)'), findsOneWidget);

      expect(find.text('Operational Performance Leaderboard'), findsOneWidget);
      expect(find.text('Vikram Singh'), findsOneWidget);
      expect(find.text('Top Performer'), findsOneWidget);
    });
  });
}
