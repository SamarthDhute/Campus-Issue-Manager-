import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../widgets/stats_card.dart';

class OperatorDashboardView extends StatelessWidget {
  const OperatorDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Operator Workload Summary
          const Text(
            'Operator Dispatch & Workload',
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
                  title: 'Assigned to Me',
                  value: '0',
                  icon: Icons.assignment_ind_outlined,
                  color: AppTheme.primaryIndigo,
                  subtitle: 'Needs action',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatsCard(
                  title: 'In Progress',
                  value: '0',
                  icon: Icons.build_circle_outlined,
                  color: AppTheme.statusAmber,
                  subtitle: 'Investigation active',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatsCard(
                  title: 'Resolved Today',
                  value: '0',
                  icon: Icons.task_alt_rounded,
                  color: AppTheme.statusGreen,
                  subtitle: 'Completed',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Active Queue / Empty State
          const Text(
            'Assigned Issue Queue',
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
              title: 'Queue is Clear',
              description: 'You currently have no unassigned or pending issues requiring investigation.',
              icon: Icons.checklist_rtl_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
