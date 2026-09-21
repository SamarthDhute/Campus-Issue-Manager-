import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../state/analytics_provider.dart';
import '../widgets/category_breakdown_widget.dart';
import '../widgets/executive_kpi_card.dart';
import '../widgets/location_hotspots_widget.dart';
import '../widgets/operator_leaderboard_widget.dart';
import '../widgets/time_range_filter_bar.dart';

class AnalyticsDashboardView extends StatefulWidget {
  const AnalyticsDashboardView({Key? key}) : super(key: key);

  @override
  State<AnalyticsDashboardView> createState() => _AnalyticsDashboardViewState();
}

class _AnalyticsDashboardViewState extends State<AnalyticsDashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AnalyticsProvider>(context, listen: false);
      if (provider.overview == null) {
        provider.loadAllAnalytics();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.overview == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryBlue),
          );
        }

        if (provider.errorMessage != null && provider.overview == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.statusRed, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load analytics',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.errorMessage!,
                    style: const TextStyle(color: AppTheme.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => provider.loadAllAnalytics(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final overview = provider.overview;

        return RefreshIndicator(
          onRefresh: () => provider.loadAllAnalytics(),
          color: AppTheme.primaryBlue,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header with Title and Filter Bar
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 700;
                    if (isWide) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Executive & Operational Insights',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Real-time campus infrastructure performance, SLAs, and operational efficiency.',
                                style: TextStyle(fontSize: 13.5, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                          TimeRangeFilterBar(
                            selectedRange: provider.selectedTimeRange,
                            onSelected: (range) => provider.setTimeRange(range),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Executive & Operational Insights',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Real-time campus infrastructure performance and SLAs.',
                            style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                          ),
                          const SizedBox(height: 16),
                          TimeRangeFilterBar(
                            selectedRange: provider.selectedTimeRange,
                            onSelected: (range) => provider.setTimeRange(range),
                          ),
                        ],
                      );
                    }
                  },
                ),

                const SizedBox(height: 24),

                // Executive KPI Cards Grid
                if (overview != null)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      int crossAxisCount = 4;
                      if (width < 600) {
                        crossAxisCount = 1;
                      } else if (width < 1000) {
                        crossAxisCount = 2;
                      }

                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: crossAxisCount == 1 ? 2.3 : 1.4,
                        children: [
                          ExecutiveKpiCard(
                            title: 'Total Incidents',
                            value: '${overview.totalIssuesCount}',
                            subtitle: '${overview.activeIssuesCount} currently active',
                            icon: Icons.confirmation_number_outlined,
                            accentColor: AppTheme.primaryBlue,
                            badgeText: overview.resolutionEfficiencyTrend,
                          ),
                          ExecutiveKpiCard(
                            title: 'SLA Compliance Rate',
                            value: '${overview.slaComplianceRate.toStringAsFixed(1)}%',
                            subtitle: '${overview.breachedIssuesCount} breaches recorded',
                            icon: Icons.verified_user_outlined,
                            accentColor: overview.slaComplianceRate >= 90
                                ? AppTheme.statusGreen
                                : AppTheme.statusRed,
                            badgeText: overview.slaComplianceRate >= 95 ? 'Target Exceeded' : 'Under Review',
                          ),
                          ExecutiveKpiCard(
                            title: 'Mean Time to Resolve (MTTR)',
                            value: '${overview.averageResolutionHours.toStringAsFixed(1)} hrs',
                            subtitle: 'Avg response: ${overview.averageResponseHours.toStringAsFixed(1)} hrs',
                            icon: Icons.timer_outlined,
                            accentColor: AppTheme.primaryIndigo,
                            badgeText: 'Optimal Speed',
                          ),
                          ExecutiveKpiCard(
                            title: 'Campus CSAT Satisfaction',
                            value: '${overview.averageCsatRating.toStringAsFixed(1)} / 5.0',
                            subtitle: 'Based on ${overview.totalFeedbacksCount} verified reviews',
                            icon: Icons.star_rounded,
                            accentColor: const Color(0xFFF59E0B),
                            badgeText: '★★★★★',
                          ),
                        ],
                      );
                    },
                  ),

                const SizedBox(height: 24),

                // Operational Insights: Hotspots & Category Breakdown
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 900;
                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 6,
                            child: LocationHotspotsWidget(hotspots: provider.hotspots),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 4,
                            child: CategoryBreakdownWidget(categories: provider.categories),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          LocationHotspotsWidget(hotspots: provider.hotspots),
                          const SizedBox(height: 20),
                          CategoryBreakdownWidget(categories: provider.categories),
                        ],
                      );
                    }
                  },
                ),

                const SizedBox(height: 24),

                // Staff Leaderboard
                OperatorLeaderboardWidget(leaderboard: provider.leaderboard),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}
