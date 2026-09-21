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
  String _selectedFilter = 'ALL'; // 'ALL', 'RESOLVED', 'PENDING'

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
    final resolvedCount = allIssues.where((i) => i.status == 'CLOSED' || i.status == 'RESOLVED_PENDING_CONFIRMATION').length;
    final pendingCount = totalCount - resolvedCount;
    final compliance = totalCount == 0 ? 100 : ((resolvedCount / totalCount) * 100).round();

    // Unique categories count
    final activeCategories = allIssues.map((i) => i.categoryName).where((c) => c != null).toSet().length;

    final filteredIssues = allIssues.where((i) {
      if (_selectedFilter == 'RESOLVED') {
        return i.status == 'CLOSED' || i.status == 'RESOLVED_PENDING_CONFIRMATION';
      }
      if (_selectedFilter == 'PENDING') {
        return i.status != 'CLOSED' && i.status != 'RESOLVED_PENDING_CONFIRMATION';
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
                    subtitle: 'Click to view all',
                    isSelected: _selectedFilter == 'ALL',
                    onTap: () => setState(() => _selectedFilter = 'ALL'),
                  ),
                  const SizedBox(height: 12, width: 12),
                  StatsCard(
                    title: 'Resolution Rate',
                    value: '$compliance%',
                    icon: Icons.speed_rounded,
                    color: AppTheme.statusGreen,
                    subtitle: 'Click to view resolved ($resolvedCount)',
                    isSelected: _selectedFilter == 'RESOLVED',
                    onTap: () => setState(() => _selectedFilter = _selectedFilter == 'RESOLVED' ? 'ALL' : 'RESOLVED'),
                  ),
                  const SizedBox(height: 12, width: 12),
                  StatsCard(
                    title: 'Pending Issues',
                    value: '$pendingCount',
                    icon: Icons.pending_actions_rounded,
                    color: AppTheme.statusAmber,
                    subtitle: 'Click to view active',
                    isSelected: _selectedFilter == 'PENDING',
                    onTap: () => setState(() => _selectedFilter = _selectedFilter == 'PENDING' ? 'ALL' : 'PENDING'),
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

            // Executive Activity Log
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedFilter == 'ALL'
                      ? 'Live Campus Activity Log'
                      : _selectedFilter == 'RESOLVED'
                          ? 'Resolved Incidents Log'
                          : 'Pending Campus Incidents',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                if (filteredIssues.isNotEmpty)
                  Text(
                    '${filteredIssues.length} total',
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
                  title: _selectedFilter == 'ALL' ? 'No Campus Issues' : 'No matching issues',
                  description: _selectedFilter == 'ALL'
                      ? 'No operational issues reported across campus yet.'
                      : 'No issues match the selected filter.',
                  icon: Icons.domain_verification_rounded,
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
