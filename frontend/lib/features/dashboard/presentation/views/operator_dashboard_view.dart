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
  String _selectedFilter = 'ALL'; // 'ALL', 'IN_PROGRESS', 'RESOLVED'

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
    final allIssues = issueProvider.issues;

    final assignedCount = allIssues.length;
    final inProgressCount = allIssues.where((i) =>
        i.status == 'INVESTIGATING' ||
        i.status == 'ACTION_SCHEDULED' ||
        i.status == 'ACTION_IN_PROGRESS').length;
    final resolvedCount = allIssues.where((i) =>
        i.status == 'RESOLVED_PENDING_CONFIRMATION' || i.status == 'CLOSED').length;

    final filteredIssues = allIssues.where((i) {
      if (_selectedFilter == 'IN_PROGRESS') {
        return i.status == 'INVESTIGATING' ||
            i.status == 'ACTION_SCHEDULED' ||
            i.status == 'ACTION_IN_PROGRESS';
      }
      if (_selectedFilter == 'RESOLVED') {
        return i.status == 'RESOLVED_PENDING_CONFIRMATION' || i.status == 'CLOSED';
      }
      return true;
    }).toList();

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
                    subtitle: 'Click to view all',
                    isSelected: _selectedFilter == 'ALL',
                    onTap: () => setState(() => _selectedFilter = 'ALL'),
                  ),
                  const SizedBox(height: 12, width: 12),
                  StatsCard(
                    title: 'In Progress',
                    value: '$inProgressCount',
                    icon: Icons.build_circle_outlined,
                    color: AppTheme.statusAmber,
                    subtitle: 'Click to filter',
                    isSelected: _selectedFilter == 'IN_PROGRESS',
                    onTap: () => setState(() => _selectedFilter = 'IN_PROGRESS'),
                  ),
                  const SizedBox(height: 12, width: 12),
                  StatsCard(
                    title: 'Resolved',
                    value: '$resolvedCount',
                    icon: Icons.task_alt_rounded,
                    color: AppTheme.statusGreen,
                    subtitle: 'Click to filter',
                    isSelected: _selectedFilter == 'RESOLVED',
                    onTap: () => setState(() => _selectedFilter = 'RESOLVED'),
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

            // Filter Chips Bar
            Row(
              children: [
                ActionChip(
                  label: Text('All ($assignedCount)'),
                  avatar: Icon(Icons.list_alt, size: 16, color: _selectedFilter == 'ALL' ? Colors.white : AppTheme.textDark),
                  backgroundColor: _selectedFilter == 'ALL' ? AppTheme.primaryIndigo : AppTheme.surfaceWhite,
                  labelStyle: TextStyle(
                    color: _selectedFilter == 'ALL' ? Colors.white : AppTheme.textDark,
                    fontWeight: _selectedFilter == 'ALL' ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  onPressed: () => setState(() => _selectedFilter = 'ALL'),
                ),
                const SizedBox(width: 8),
                ActionChip(
                  label: Text('In Progress ($inProgressCount)'),
                  avatar: Icon(Icons.engineering_outlined, size: 16, color: _selectedFilter == 'IN_PROGRESS' ? Colors.white : AppTheme.statusAmber),
                  backgroundColor: _selectedFilter == 'IN_PROGRESS' ? AppTheme.statusAmber : AppTheme.surfaceWhite,
                  labelStyle: TextStyle(
                    color: _selectedFilter == 'IN_PROGRESS' ? Colors.white : AppTheme.textDark,
                    fontWeight: _selectedFilter == 'IN_PROGRESS' ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  onPressed: () => setState(() => _selectedFilter = 'IN_PROGRESS'),
                ),
                const SizedBox(width: 8),
                ActionChip(
                  label: Text('Resolved ($resolvedCount)'),
                  avatar: Icon(Icons.check_circle_outline, size: 16, color: _selectedFilter == 'RESOLVED' ? Colors.white : AppTheme.statusGreen),
                  backgroundColor: _selectedFilter == 'RESOLVED' ? AppTheme.statusGreen : AppTheme.surfaceWhite,
                  labelStyle: TextStyle(
                    color: _selectedFilter == 'RESOLVED' ? Colors.white : AppTheme.textDark,
                    fontWeight: _selectedFilter == 'RESOLVED' ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  onPressed: () => setState(() => _selectedFilter = 'RESOLVED'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Active Queue
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedFilter == 'ALL'
                      ? 'Assigned Issue Queue'
                      : _selectedFilter == 'IN_PROGRESS'
                          ? 'In-Progress Queue'
                          : 'Resolved Cases',
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
                  title: _selectedFilter == 'ALL' ? 'Queue is Clear' : 'No matching issues',
                  description: _selectedFilter == 'ALL'
                      ? 'You currently have no pending issues assigned to you.'
                      : 'No issues match the selected filter.',
                  icon: Icons.checklist_rtl_rounded,
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
