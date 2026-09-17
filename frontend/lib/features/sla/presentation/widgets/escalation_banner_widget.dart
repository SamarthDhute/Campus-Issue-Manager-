import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/state/auth_provider.dart';
import '../state/sla_provider.dart';
import 'manual_escalate_modal.dart';

class EscalationBannerWidget extends StatelessWidget {
  final String issueId;
  final String issueNumber;

  const EscalationBannerWidget({
    super.key,
    required this.issueId,
    required this.issueNumber,
  });

  @override
  Widget build(BuildContext context) {
    final slaProvider = context.watch<SlaProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isStaff = authProvider.isOperator || authProvider.isTeamLead || authProvider.isManager || authProvider.isAdmin;

    final openEscalations = slaProvider.escalations.where((e) => e.status == 'OPEN').toList();

    return Column(
      children: [
        if (openEscalations.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFCA5A5), width: 1.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppTheme.statusRed, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'TIER ${openEscalations.first.level} ESCALATION ACTIVE',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF991B1B),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.statusRed.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              openEscalations.first.triggerType.replaceAll('_', ' '),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.statusRed),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        openEscalations.first.reason,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF7F1D1D)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Triggered by: ${openEscalations.first.triggeredByName} (${openEscalations.first.triggeredByRole})',
                        style: const TextStyle(fontSize: 11, color: Color(0xFFB91C1C), fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        // Staff Escalation Action Button
        if (isStaff && openEscalations.isEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.statusRed,
                side: const BorderSide(color: Color(0xFFFCA5A5)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => ManualEscalateModal.show(context, issueId: issueId, issueNumber: issueNumber),
              icon: const Icon(Icons.priority_high_rounded, size: 18),
              label: const Text('Escalate Case to Higher Tier', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
      ],
    );
  }
}
