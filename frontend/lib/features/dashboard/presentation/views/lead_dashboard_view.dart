import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../widgets/stats_card.dart';

class LeadDashboardView extends StatelessWidget {
  const LeadDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Team Lead Overview
          const Text(
            'Team Performance & Risk Radar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: StatsCard(
                  title: 'Team Workload',
                  value: '0',
                  icon: Icons.groups_outlined,
                  color: AppTheme.primaryBlue,
                  subtitle: 'Total team cases',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatsCard(
                  title: 'SLA Risks',
                  value: '0',
                  icon: Icons.warning_amber_rounded,
                  color: AppTheme.statusRed,
                  subtitle: 'Near breach',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatsCard(
                  title: 'Unassigned',
                  value: '0',
                  icon: Icons.person_search_rounded,
                  color: AppTheme.statusAmber,
                  subtitle: 'Needs routing',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Team Queue / Empty State
          const Text(
            'Team Queue & Escalations',
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
              title: 'No Pending Escalations',
              description: 'Team operations are healthy. When cases require reassignment or risk intervention, they will appear here.',
              icon: Icons.shield_outlined,
            ),
          ),
        ],
      ),
    );
  }
}
