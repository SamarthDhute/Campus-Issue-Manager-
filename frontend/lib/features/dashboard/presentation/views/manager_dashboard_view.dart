import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../issues/presentation/screens/issue_detail_screen.dart';
import '../../../issues/presentation/widgets/issue_card.dart';
import '../../../issues/state/issue_provider.dart';
import '../widgets/stats_card.dart';

class ManagerDashboardView extends StatefulWidget {
  const ManagerDashboardView({super.key});

  @override
  State<ManagerDashboardView> createState() => _ManagerDashboardViewState();
}

class _ManagerDashboardViewState extends State<ManagerDashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IssueProvider>().loadIssues();
    });
  }

  @override
  Widget build(BuildContext context) {
    final issueProvider = context.watch<IssueProvider>();
    final issues = issueProvider.issues;

    final totalCount = issues.length;
    final resolvedCount = issues.where((i) => i.status == 'CLOSED' || i.status == 'RESOLVED_PENDING_CONFIRMATION').length;
    final compliance = totalCount == 0 ? 100 : ((resolvedCount / totalCount) * 100).round();

    // Unique categories count
    final activeCategories = issues.map((i) => i.categoryName).where((c) => c != null).toSet().length;

    return RefreshIndicator(
      onRefresh: () => context.read<IssueProvider>().loadIssues(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                final cards = [
                  StatsCard(
                    title: 'Total Issues',
                    value: '$totalCount',
                    icon: Icons.analytics_outlined,
                    color: AppTheme.primaryBlue,
                    subtitle: 'All-time volume',
                  ),
                  const SizedBox(height: 12, width: 12),
                  StatsCard(
                    title: 'Resolution Rate',
                    value: '$compliance%',
                    icon: Icons.speed_rounded,
                    color: AppTheme.statusGreen,
                    subtitle: '$resolvedCount resolved',
                  ),
                  const SizedBox(height: 12, width: 12),
                  StatsCard(
                    title: 'Active Sectors',
                    value: '${activeCategories > 0 ? activeCategories : 4}',
                    icon: Icons.apartment_rounded,
                    color: AppTheme.primaryIndigo,
                    subtitle: 'Departments',
                  ),
                ];

                if (isNarrow) {
                  return Column(children: cards);
                }
                return Row(
                  children: [
                    Expanded(child: cards[0]),
                    const SizedBox(width: 12),
                    Expanded(child: cards[2]),
                    const SizedBox(width: 12),
                    Expanded(child: cards[4]),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Campus Issues Stream
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Campus-wide Issue Stream',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                if (issues.isNotEmpty)
                  Text(
                    '${issues.length} records',
                    style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (issueProvider.isLoading && issues.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (issues.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: const EmptyStateView(
                  title: 'Operational Baseline Active',
                  description: 'Campus-wide SLA trends and problem records will display here as tickets are submitted.',
                  icon: Icons.insights_rounded,
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: issues.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final issue = issues[index];
                  return IssueCard(
                    issue: issue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => IssueDetailScreen(issueId: issue.id),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
