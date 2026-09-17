import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../issues/presentation/screens/issue_detail_screen.dart';
import '../../../issues/presentation/widgets/issue_card.dart';
import '../../../issues/state/issue_provider.dart';
import '../widgets/stats_card.dart';

class OperatorDashboardView extends StatefulWidget {
  const OperatorDashboardView({super.key});

  @override
  State<OperatorDashboardView> createState() => _OperatorDashboardViewState();
}

class _OperatorDashboardViewState extends State<OperatorDashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IssueProvider>().loadIssues(assignedToMe: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final issueProvider = context.watch<IssueProvider>();
    final issues = issueProvider.issues;

    final assignedCount = issues.length;
    final inProgressCount = issues.where((i) =>
        i.status == 'INVESTIGATING' ||
        i.status == 'ACTION_SCHEDULED' ||
        i.status == 'ACTION_IN_PROGRESS').length;
    final resolvedCount = issues.where((i) =>
        i.status == 'RESOLVED_PENDING_CONFIRMATION' || i.status == 'CLOSED').length;

    return RefreshIndicator(
      onRefresh: () => context.read<IssueProvider>().loadIssues(assignedToMe: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 600;
                final cards = [
                  StatsCard(
                    title: 'Assigned to Me',
                    value: '$assignedCount',
                    icon: Icons.assignment_ind_outlined,
                    color: AppTheme.primaryIndigo,
                    subtitle: 'Total assigned',
                  ),
                  const SizedBox(height: 12, width: 12),
                  StatsCard(
                    title: 'In Progress',
                    value: '$inProgressCount',
                    icon: Icons.build_circle_outlined,
                    color: AppTheme.statusAmber,
                    subtitle: 'Active cases',
                  ),
                  const SizedBox(height: 12, width: 12),
                  StatsCard(
                    title: 'Resolved',
                    value: '$resolvedCount',
                    icon: Icons.task_alt_rounded,
                    color: AppTheme.statusGreen,
                    subtitle: 'Completed',
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

            // Active Queue
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Assigned Issue Queue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                if (issues.isNotEmpty)
                  Text(
                    '${issues.length} cases',
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
                  title: 'Queue is Clear',
                  description: 'You currently have no pending issues assigned to you.',
                  icon: Icons.checklist_rtl_rounded,
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
