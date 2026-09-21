import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_campus_issue_manager/core/theme/app_theme.dart';
import 'package:smart_campus_issue_manager/features/auth/state/auth_provider.dart';
import '../../data/models/issue_model.dart';
import '../../data/models/timeline_event_model.dart';
import '../../state/issue_provider.dart';
import '../../../operations/state/operations_provider.dart';
import '../../../operations/presentation/widgets/smart_assignment_card.dart';
import '../../../operations/presentation/widgets/tasks_checklist_widget.dart';
import '../../../operations/presentation/widgets/investigation_log_widget.dart';
import '../../../operations/presentation/widgets/internal_notes_widget.dart';
import '../../../operations/presentation/widgets/requester_chat_widget.dart';
import '../../../sla/presentation/state/sla_provider.dart';
import '../../../sla/presentation/widgets/sla_countdown_card.dart';
import '../../../sla/presentation/widgets/risk_signals_card.dart';
import '../../../sla/presentation/widgets/escalation_banner_widget.dart';
import '../../../resolution/state/resolution_provider.dart';
import '../../../resolution/presentation/widgets/resolution_verification_card.dart';
import '../../../resolution/presentation/widgets/resolution_evidence_widget.dart';
import '../widgets/ai_case_intelligence_card.dart';
import '../widgets/priority_chip.dart';
import '../widgets/status_chip.dart';

class IssueDetailScreen extends StatefulWidget {
  final String issueId;

  const IssueDetailScreen({super.key, required this.issueId});

  @override
  State<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen> with SingleTickerProviderStateMixin {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IssueProvider>().loadIssueDetails(widget.issueId);
      final userRole = context.read<AuthProvider>().user?.role.toUpperCase() ?? 'STUDENT';
      context.read<OperationsProvider>().loadOperationsData(widget.issueId, isStaff: userRole != 'STUDENT');
      context.read<SlaProvider>().loadSlaData(widget.issueId);
      context.read<ResolutionProvider>().loadAllResolutionData(widget.issueId);
    });
  }

  void _showStatusUpdateDialog(BuildContext context, String currentStatus, String targetStatus, String title) {
    final commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update status from $currentStatus to $targetStatus?',
              style: const TextStyle(fontSize: 14, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Activity / Resolution Note (Optional)',
                hintText: 'Add details or remarks for the timeline...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final success = await context.read<IssueProvider>().updateIssueStatus(
                    widget.issueId,
                    targetStatus,
                    comment: commentController.text.trim().isEmpty ? null : commentController.text.trim(),
                  );
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Status updated to $targetStatus'),
                      backgroundColor: AppTheme.statusGreen,
                    ),
                  );
                } else {
                  final err = context.read<IssueProvider>().errorMessage ?? 'Failed to update status';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(err), backgroundColor: AppTheme.statusRed),
                  );
                }
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showAssignDialog(BuildContext context, IssueModel issue) {
    final teamController = TextEditingController(text: issue.assignedTeamName ?? '');
    final userController = TextEditingController(text: issue.assignedUserName ?? '');
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Assign Case / Team'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: teamController,
                decoration: const InputDecoration(
                  labelText: 'Assigned Department / Team',
                  hintText: 'e.g. Electrical Services, Facilities',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: userController,
                decoration: const InputDecoration(
                  labelText: 'Assigned Operator / Staff Name',
                  hintText: 'e.g. Tech Support Lead',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Assignment Note',
                  hintText: 'Reason or instructions for assignee...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final success = await context.read<IssueProvider>().assignIssue(
                    widget.issueId,
                    assignedTeamId: teamController.text.trim().isEmpty ? null : teamController.text.trim(),
                    assignedUserId: userController.text.trim().isEmpty ? null : userController.text.trim(),
                    comment: commentController.text.trim().isEmpty ? null : commentController.text.trim(),
                  );
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Assignment updated successfully'),
                      backgroundColor: AppTheme.statusGreen,
                    ),
                  );
                } else {
                  final err = context.read<IssueProvider>().errorMessage ?? 'Failed to assign';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(err), backgroundColor: AppTheme.statusRed),
                  );
                }
              }
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final issueProvider = context.watch<IssueProvider>();
    final authProvider = context.watch<AuthProvider>();
    final userRole = authProvider.user?.role.toUpperCase() ?? 'STUDENT';
    final issue = issueProvider.selectedIssue;

    return Scaffold(
      appBar: AppBar(
        title: Text(issue?.issueNumber ?? 'Issue Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => issueProvider.loadIssueDetails(widget.issueId),
          ),
        ],
      ),
      body: issueProvider.isLoading && issue == null
          ? const Center(child: CircularProgressIndicator())
          : issue == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppTheme.statusRed),
                      const SizedBox(height: 12),
                      Text(
                        issueProvider.errorMessage ?? 'Issue not found',
                        style: const TextStyle(fontSize: 16, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => issueProvider.loadIssueDetails(widget.issueId),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await issueProvider.loadIssueDetails(widget.issueId);
                    if (mounted) {
                      await context.read<OperationsProvider>().loadOperationsData(widget.issueId, isStaff: userRole != 'STUDENT');
                      await context.read<SlaProvider>().loadSlaData(widget.issueId);
                    }
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeaderCard(issue),
                            const SizedBox(height: 16),
                            _buildSegmentedTabNav(userRole != 'STUDENT'),
                            const SizedBox(height: 16),
                            _buildActiveTabContent(issue, userRole),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildSegmentedTabNav(bool isStaff) {
    final tabs = [
      {'label': 'Overview & AI', 'icon': Icons.insights_rounded},
      {'label': 'Tasks & Field Ops', 'icon': Icons.assignment_turned_in_rounded},
      if (isStaff) {'label': 'Staff Notes', 'icon': Icons.lock_clock_rounded},
      {'label': 'Chat & Comms', 'icon': Icons.forum_rounded},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.borderSubtle.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = _selectedTabIndex == index;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: InkWell(
                onTap: () => setState(() => _selectedTabIndex = index),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tabs[index]['icon'] as IconData,
                        size: 16,
                        color: isSelected ? Colors.white : AppTheme.textDark,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tabs[index]['label'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildActiveTabContent(IssueModel issue, String userRole) {
    final isStaff = userRole != 'STUDENT';

    // Tab mapping
    if (_selectedTabIndex == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResolutionVerificationCard(issue: issue),
          const SizedBox(height: 12),
          EscalationBannerWidget(issueId: issue.id, issueNumber: issue.issueNumber),
          SlaCountdownCard(issueId: issue.id),
          RiskSignalsCard(issueId: issue.id),
          const SizedBox(height: 16),
          ResolutionEvidenceWidget(issueId: issue.id, canUpload: isStaff),
          const SizedBox(height: 16),
          AiCaseIntelligenceCard(issue: issue),
          _buildActionToolbar(context, issue, userRole),
          const SizedBox(height: 16),
          _buildDetailsCard(issue),
          const SizedBox(height: 24),
          _buildTimelineSection(issue.timeline),
        ],
      );
    } else if (_selectedTabIndex == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (userRole == 'TEAM_LEAD' || userRole == 'CAMPUS_MANAGER' || userRole == 'MANAGER' || userRole == 'ADMIN')
            SmartAssignmentCard(issue: issue),
          TasksChecklistWidget(issue: issue, isStaff: isStaff),
          const SizedBox(height: 12),
          InvestigationLogWidget(issue: issue, isStaff: isStaff),
          const SizedBox(height: 12),
          ResolutionEvidenceWidget(issueId: issue.id, canUpload: isStaff),
        ],
      );
    } else if (_selectedTabIndex == 2 && isStaff) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InternalNotesWidget(issue: issue),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RequesterChatWidget(issue: issue),
        ],
      );
    }
  }

  Widget _buildHeaderCard(IssueModel issue) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        issue.issueNumber,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        issue.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    PriorityChip(priority: issue.priority),
                    StatusChip(status: issue.status),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              issue.description,
              style: const TextStyle(fontSize: 15, color: AppTheme.textDark, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionToolbar(BuildContext context, IssueModel issue, String role) {
    final isOperator = role == 'OPERATOR' || role == 'FACULTY_STAFF' || role == 'STAFF';
    final isLeadOrManager = role == 'TEAM_LEAD' || role == 'CAMPUS_MANAGER' || role == 'MANAGER' || role == 'ADMIN';

    final buttons = <Widget>[];

    // Status-specific action buttons
    if (issue.status == 'REPORTED' && (isOperator || isLeadOrManager)) {
      buttons.add(
        ElevatedButton.icon(
          icon: const Icon(Icons.search, size: 18),
          label: const Text('Start Investigation'),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryIndigo),
          onPressed: () => _showStatusUpdateDialog(context, issue.status, 'INVESTIGATING', 'Begin Investigation'),
        ),
      );
    } else if (issue.status == 'TRIAGED' && (isOperator || isLeadOrManager)) {
      buttons.add(
        ElevatedButton.icon(
          icon: const Icon(Icons.search, size: 18),
          label: const Text('Start Investigation'),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryIndigo),
          onPressed: () => _showStatusUpdateDialog(context, issue.status, 'INVESTIGATING', 'Begin Investigation'),
        ),
      );
    } else if (issue.status == 'INVESTIGATING' && (isOperator || isLeadOrManager)) {
      buttons.add(
        ElevatedButton.icon(
          icon: const Icon(Icons.schedule, size: 18),
          label: const Text('Schedule Action'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
          onPressed: () => _showStatusUpdateDialog(context, issue.status, 'ACTION_SCHEDULED', 'Schedule Maintenance'),
        ),
      );
      buttons.add(
        ElevatedButton.icon(
          icon: const Icon(Icons.build_circle, size: 18),
          label: const Text('Start Work'),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
          onPressed: () => _showStatusUpdateDialog(context, issue.status, 'ACTION_IN_PROGRESS', 'Start Field Work'),
        ),
      );
    } else if (issue.status == 'ACTION_SCHEDULED' && (isOperator || isLeadOrManager)) {
      buttons.add(
        ElevatedButton.icon(
          icon: const Icon(Icons.play_arrow, size: 18),
          label: const Text('Start Work'),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
          onPressed: () => _showStatusUpdateDialog(context, issue.status, 'ACTION_IN_PROGRESS', 'Start Field Work'),
        ),
      );
    } else if (issue.status == 'ACTION_IN_PROGRESS' && (isOperator || isLeadOrManager)) {
      buttons.add(
        ElevatedButton.icon(
          icon: const Icon(Icons.check_circle_outline, size: 18),
          label: const Text('Propose Resolution'),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusGreen),
          onPressed: () => _showStatusUpdateDialog(context, issue.status, 'RESOLVED_PENDING_CONFIRMATION', 'Propose Resolution'),
        ),
      );
    }

    // Requester confirmation / reopening
    if (issue.status == 'RESOLVED_PENDING_CONFIRMATION') {
      buttons.add(
        ElevatedButton.icon(
          icon: const Icon(Icons.verified, size: 18),
          label: const Text('Confirm Resolution & Close'),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusGreen),
          onPressed: () => _showStatusUpdateDialog(context, issue.status, 'CLOSED', 'Confirm Resolution'),
        ),
      );
      buttons.add(
        OutlinedButton.icon(
          icon: const Icon(Icons.replay, size: 18),
          label: const Text('Reopen Issue'),
          style: OutlinedButton.styleFrom(foregroundColor: AppTheme.statusRed),
          onPressed: () => _showStatusUpdateDialog(context, issue.status, 'REOPENED', 'Reopen Issue'),
        ),
      );
    } else if (issue.status == 'CLOSED') {
      buttons.add(
        OutlinedButton.icon(
          icon: const Icon(Icons.replay, size: 18),
          label: const Text('Reopen Issue'),
          style: OutlinedButton.styleFrom(foregroundColor: AppTheme.statusRed),
          onPressed: () => _showStatusUpdateDialog(context, issue.status, 'REOPENED', 'Reopen Issue'),
        ),
      );
    }

    // Lead or Manager Assignment button -> Switches directly to Smart Dispatch Tab
    if (isLeadOrManager) {
      buttons.add(
        ElevatedButton.icon(
          icon: const Icon(Icons.bolt_rounded, size: 18, color: Colors.amberAccent),
          label: const Text('Smart Dispatch & Assign'),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
          onPressed: () {
            setState(() {
              _selectedTabIndex = 1; // Switches to Tasks & Field Ops / Smart Dispatch Tab
            });
            context.read<OperationsProvider>().fetchRecommendation(widget.issueId);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Switched to Tasks & Field Ops — Smart Dispatch Engine active'),
                duration: Duration(seconds: 2),
                backgroundColor: AppTheme.primaryBlue,
              ),
            );
          },
        ),
      );
    }

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: buttons,
        ),
      ),
    );
  }

  Widget _buildDetailsCard(IssueModel issue) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Case Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const Divider(height: 24),
            _buildDetailRow(Icons.place_outlined, 'Location', issue.location),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.category_outlined, 'Category', issue.categoryName ?? 'General Campus'),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.person_outline, 'Reported By', issue.requesterName),
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.group_work_outlined,
              'Assigned Team',
              issue.assignedTeamName ?? 'Unassigned',
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.badge_outlined,
              'Assigned Operator',
              issue.assignedUserName ?? 'Not yet assigned',
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.access_time,
              'Created On',
              '${issue.createdAt.toLocal().day}/${issue.createdAt.toLocal().month}/${issue.createdAt.toLocal().year} at ${issue.createdAt.toLocal().hour}:${issue.createdAt.toLocal().minute.toString().padLeft(2, '0')}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.circle, size: 8, color: AppTheme.textMuted),
        const SizedBox(width: 8),
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: AppTheme.textDark, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineSection(List<TimelineEventModel> timeline) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Activity & Lifecycle Timeline',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            Text(
              '${timeline.length} event${timeline.length == 1 ? '' : 's'}',
              style: const TextStyle(fontSize: 14, color: AppTheme.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (timeline.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text('No timeline activity recorded yet.'),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: timeline.length,
            itemBuilder: (context, index) {
              final event = timeline[index];
              final isLast = index == timeline.length - 1;
              return _buildTimelineItem(event, isLast);
            },
          ),
      ],
    );
  }

  Widget _buildTimelineItem(TimelineEventModel event, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Card(
                elevation: 0,
                color: Colors.grey.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            event.actorName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          Text(
                            '${event.createdAt.toLocal().hour}:${event.createdAt.toLocal().minute.toString().padLeft(2, '0')} · ${event.createdAt.toLocal().day}/${event.createdAt.toLocal().month}/${event.createdAt.toLocal().year}',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.description,
                        style: const TextStyle(fontSize: 13, color: AppTheme.textDark),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
