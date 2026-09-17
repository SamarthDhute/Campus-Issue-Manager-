import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../state/sla_provider.dart';

class SlaCountdownCard extends StatelessWidget {
  final String issueId;

  const SlaCountdownCard({super.key, required this.issueId});

  String _formatDuration(int totalSeconds) {
    if (totalSeconds <= 0) return '00:00:00';
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status, bool isBreached, bool isMet) {
    if (isMet) return AppTheme.statusGreen;
    if (isBreached || status.contains('BREACHED')) return AppTheme.statusRed;
    if (status == 'AT_RISK') return AppTheme.statusAmber;
    return AppTheme.primaryIndigo;
  }

  @override
  Widget build(BuildContext context) {
    final slaProvider = context.watch<SlaProvider>();
    final sla = slaProvider.sla;

    if (slaProvider.isLoading && sla == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderSubtle),
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (sla == null) {
      return const SizedBox.shrink();
    }

    final isResponseMet = sla.responseMet;
    final isResolutionMet = sla.resolutionMet;
    final isResponseBreached = sla.responseBreached;
    final isResolutionBreached = sla.resolutionBreached;

    final primaryStatusColor = _getStatusColor(sla.status, isResolutionBreached || isResponseBreached, isResolutionMet);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryStatusColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primaryStatusColor.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: primaryStatusColor.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.timer_outlined, size: 20, color: primaryStatusColor),
                const SizedBox(width: 8),
                const Text(
                  'SLA Governance & Timers',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryStatusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    sla.status.replaceAll('_', ' '),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: primaryStatusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Milestone 1: Response SLA
                _buildMilestoneRow(
                  title: 'First Response Target',
                  subtitle: isResponseMet
                      ? 'Target met on initial staff triage'
                      : (isResponseBreached ? 'Response overdue' : 'Time remaining until operator triage'),
                  countdown: _formatDuration(slaProvider.currentResponseSeconds),
                  isMet: isResponseMet,
                  isBreached: isResponseBreached,
                  progressPercent: sla.responseProgressPercentage,
                  dueAt: sla.responseDueAt,
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: AppTheme.borderSubtle),
                ),

                // Milestone 2: Resolution SLA
                _buildMilestoneRow(
                  title: 'Resolution SLA Target',
                  subtitle: isResolutionMet
                      ? 'Case resolved within target timeframe'
                      : (isResolutionBreached ? 'Resolution SLA breached' : 'Time remaining until resolution deadline'),
                  countdown: _formatDuration(slaProvider.currentResolutionSeconds),
                  isMet: isResolutionMet,
                  isBreached: isResolutionBreached,
                  progressPercent: sla.resolutionProgressPercentage,
                  dueAt: sla.resolutionDueAt,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneRow({
    required String title,
    required String subtitle,
    required String countdown,
    required bool isMet,
    required bool isBreached,
    required double progressPercent,
    DateTime? dueAt,
  }) {
    Color itemColor;
    IconData icon;
    String badgeText;

    if (isMet) {
      itemColor = AppTheme.statusGreen;
      icon = Icons.check_circle_outline;
      badgeText = 'MET';
    } else if (isBreached) {
      itemColor = AppTheme.statusRed;
      icon = Icons.error_outline;
      badgeText = 'BREACHED';
    } else {
      itemColor = AppTheme.primaryIndigo;
      icon = Icons.hourglass_top_outlined;
      badgeText = countdown;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: itemColor),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: itemColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                  color: itemColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (progressPercent / 100.0).clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: AppTheme.borderSubtle,
            valueColor: AlwaysStoppedAnimation<Color>(itemColor),
          ),
        ),
      ],
    );
  }
}
