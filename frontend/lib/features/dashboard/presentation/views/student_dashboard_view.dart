import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../issues/presentation/screens/create_issue_screen.dart';
import '../../../issues/presentation/screens/issue_detail_screen.dart';
import '../../../issues/presentation/widgets/issue_card.dart';
import '../../../issues/state/issue_provider.dart';
import '../widgets/stats_card.dart';

class StudentDashboardView extends StatefulWidget {
  const StudentDashboardView({super.key});

  @override
  State<StudentDashboardView> createState() => _StudentDashboardViewState();
}

class _StudentDashboardViewState extends State<StudentDashboardView> {
  String _selectedFilter = 'ALL'; // 'ALL', 'ACTIVE', 'RESOLVED'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IssueProvider>().loadIssues(myIssues: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final issueProvider = context.watch<IssueProvider>();
    final allIssues = issueProvider.issues;
    final activeCount = allIssues.where((i) => i.status != 'CLOSED' && i.status != 'RESOLVED_PENDING_CONFIRMATION').length;
    final resolvedCount = allIssues.where((i) => i.status == 'CLOSED' || i.status == 'RESOLVED_PENDING_CONFIRMATION').length;

    final filteredIssues = allIssues.where((i) {
      if (_selectedFilter == 'ACTIVE') {
        return i.status != 'CLOSED' && i.status != 'RESOLVED_PENDING_CONFIRMATION';
      }
      if (_selectedFilter == 'RESOLVED') {
        return i.status == 'CLOSED' || i.status == 'RESOLVED_PENDING_CONFIRMATION';
      }
      return true;
    }).toList();

    return RefreshIndicator(
      onRefresh: () => context.read<IssueProvider>().loadIssues(myIssues: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting & Action Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.primaryIndigo],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.school_rounded, color: Colors.white, size: 24),
                      SizedBox(width: 10),
                      Text(
                        'Welcome to Student Portal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Report maintenance, electrical, hostel, or IT issues across campus. Track real-time progress and timeline updates.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CreateIssueScreen()),
                      );
                    },
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: const Text('Report New Issue'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryBlue,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    title: 'Active Issues',
                    value: '$activeCount',
                    icon: Icons.pending_actions_rounded,
                    color: AppTheme.statusAmber,
                    subtitle: 'Click to filter',
                    isSelected: _selectedFilter == 'ACTIVE',
                    onTap: () => setState(() => _selectedFilter = _selectedFilter == 'ACTIVE' ? 'ALL' : 'ACTIVE'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    title: 'Resolved',
                    value: '$resolvedCount',
                    icon: Icons.check_circle_outline_rounded,
                    color: AppTheme.statusGreen,
                    subtitle: 'Click to filter',
                    isSelected: _selectedFilter == 'RESOLVED',
                    onTap: () => setState(() => _selectedFilter = _selectedFilter == 'RESOLVED' ? 'ALL' : 'RESOLVED'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Submissions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedFilter == 'ALL'
                      ? 'Recent Submissions'
                      : _selectedFilter == 'ACTIVE'
                          ? 'Active Submissions'
                          : 'Resolved Submissions',
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
                  title: _selectedFilter == 'ALL' ? 'No Issues Reported Yet' : 'No matching issues',
                  description: _selectedFilter == 'ALL'
                      ? 'Tap "Report New Issue" above to submit your first campus issue.'
                      : 'No issues match the selected filter.',
                  icon: Icons.assignment_outlined,
                  action: _selectedFilter == 'ALL'
                      ? ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CreateIssueScreen()),
                            );
                          },
                          child: const Text('Create Issue'),
                        )
                      : null,
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
