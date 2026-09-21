import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../issues/presentation/screens/issue_detail_screen.dart';
import '../../../issues/presentation/widgets/issue_card.dart';
import '../../../issues/state/issue_provider.dart';
import '../widgets/stats_card.dart';

class LeadDashboardView extends StatefulWidget {
  const LeadDashboardView({super.key});

  @override
  State<LeadDashboardView> createState() => _LeadDashboardViewState();
}

class _LeadDashboardViewState extends State<LeadDashboardView> {
  String _selectedFilter = 'ALL'; // 'ALL', 'SLA_RISK', 'UNASSIGNED'

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
    final allIssues = issueProvider.issues;

    final totalCount = allIssues.length;
    final slaRiskCount = allIssues.where((i) =>
        (i.priority == 'HIGH' || i.priority == 'CRITICAL') &&
        (i.status != 'CLOSED' && i.status != 'RESOLVED_PENDING_CONFIRMATION')).length;
    final unassignedCount = allIssues.where((i) => i.assignedUserId == null || i.assignedTeamId == null).length;

    final filteredIssues = allIssues.where((i) {
      if (_selectedFilter == 'SLA_RISK') {
        return (i.priority == 'HIGH' || i.priority == 'CRITICAL') &&
            (i.status != 'CLOSED' && i.status != 'RESOLVED_PENDING_CONFIRMATION');
      }
      if (_selectedFilter == 'UNASSIGNED') {
        return i.assignedUserId == null || i.assignedTeamId == null;
      }
      return true;
    }).toList();

    return RefreshIndicator(
      onRefresh: () => context.read<IssueProvider>().loadIssues(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 600;
                final cards = [
                  StatsCard(
                    title: 'Team Workload',
                    value: '$totalCount',
                    icon: Icons.groups_outlined,
                    color: AppTheme.primaryBlue,
                    subtitle: 'Click to view all',
                    isSelected: _selectedFilter == 'ALL',
                    onTap: () => setState(() => _selectedFilter = 'ALL'),
                  ),
                  const SizedBox(height: 12, width: 12),
                  StatsCard(
                    title: 'SLA Risks',
                    value: '$slaRiskCount',
                    icon: Icons.warning_amber_rounded,
                    color: AppTheme.statusRed,
                    subtitle: 'Click to filter',
                    isSelected: _selectedFilter == 'SLA_RISK',
                    onTap: () => setState(() => _selectedFilter = 'SLA_RISK'),
                  ),
                  const SizedBox(height: 12, width: 12),
                  StatsCard(
                    title: 'Unassigned',
                    value: '$unassignedCount',
                    icon: Icons.person_search_rounded,
                    color: AppTheme.statusAmber,
                    subtitle: 'Click to filter',
                    isSelected: _selectedFilter == 'UNASSIGNED',
                    onTap: () => setState(() => _selectedFilter = 'UNASSIGNED'),
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

            // Team Queue
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedFilter == 'ALL'
                      ? 'Team Queue & Escalations'
                      : _selectedFilter == 'SLA_RISK'
                          ? 'High Risk / Escalated Queue'
                          : 'Unassigned Routing Queue',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                if (filteredIssues.isNotEmpty)
                  Text(
                    '${filteredIssues.length} cases',
                    style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (issueProvider.isLoading && allIssues.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (filteredIssues.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: EmptyStateView(
                  title: _selectedFilter == 'ALL' ? 'No Active Issues' : 'No matching cases',
                  description: _selectedFilter == 'ALL'
                      ? 'Team operations are clear. All campus cases have been resolved.'
                      : 'No issues match the selected filter.',
                  icon: Icons.shield_outlined,
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredIssues.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final issue = filteredIssues[index];
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
