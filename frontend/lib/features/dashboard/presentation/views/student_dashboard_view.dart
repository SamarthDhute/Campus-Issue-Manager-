import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../widgets/stats_card.dart';

class StudentDashboardView extends StatelessWidget {
  const StudentDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Action Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryBlue, AppTheme.primaryIndigo],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Report a Campus Issue',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Notice water leakage, electrical problems, or facility issues? Report instantly with AI assistance in Phase 2.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Issue Reporting will be activated in Phase 2 (Core Issue Management)'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('New Issue'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryBlue,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Overview Stats
          const Text(
            'My Issue Overview',
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
                  title: 'Active Issues',
                  value: '0',
                  icon: Icons.pending_actions_rounded,
                  color: AppTheme.statusAmber,
                  subtitle: 'Pending resolution',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatsCard(
                  title: 'Resolved',
                  value: '0',
                  icon: Icons.check_circle_outline_rounded,
                  color: AppTheme.statusGreen,
                  subtitle: 'Confirmed fixes',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Activity / Empty State
          const Text(
            'Recent Submissions',
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
              title: 'No Issues Reported Yet',
              description: 'When you submit issues around campus, their live tracking and AI updates will appear here.',
              icon: Icons.assignment_outlined,
            ),
          ),
        ],
      ),
    );
  }
}
