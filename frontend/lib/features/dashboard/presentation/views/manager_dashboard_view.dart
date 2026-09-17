import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../widgets/stats_card.dart';

class ManagerDashboardView extends StatelessWidget {
  const ManagerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campus Executive Overview
          const Text(
            'Campus Operational Intelligence',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;
              if (isNarrow) {
                return const Column(
                  children: [
                    StatsCard(
                      title: 'Total Issues',
                      value: '0',
                      icon: Icons.analytics_outlined,
                      color: AppTheme.primaryBlue,
                      subtitle: 'All-time volume',
                    ),
                    SizedBox(height: 12),
                    StatsCard(
                      title: 'SLA Compliance',
                      value: '100%',
                      icon: Icons.speed_rounded,
                      color: AppTheme.statusGreen,
                      subtitle: 'Target: >95%',
                    ),
                    SizedBox(height: 12),
                    StatsCard(
                      title: 'Active Teams',
                      value: '3',
                      icon: Icons.apartment_rounded,
                      color: AppTheme.primaryIndigo,
                      subtitle: 'Campus departments',
                    ),
                  ],
                );
              }
              return const Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      title: 'Total Issues',
                      value: '0',
                      icon: Icons.analytics_outlined,
                      color: AppTheme.primaryBlue,
                      subtitle: 'All-time volume',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: StatsCard(
                      title: 'SLA Compliance',
                      value: '100%',
                      icon: Icons.speed_rounded,
                      color: AppTheme.statusGreen,
                      subtitle: 'Target: >95%',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: StatsCard(
                      title: 'Active Teams',
                      value: '3',
                      icon: Icons.apartment_rounded,
                      color: AppTheme.primaryIndigo,
                      subtitle: 'Campus departments',
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Department Breakdown / Insights
          const Text(
            'Campus Department Health',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: const EmptyStateView(
              title: 'Operational Baseline Active',
              description: 'Campus-wide SLA trends and recurring problem heatmaps will populate as issue lifecycle data accumulates.',
              icon: Icons.insights_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
