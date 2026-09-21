import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../state/sla_provider.dart';

class RiskSignalsCard extends StatelessWidget {
  final String issueId;

  const RiskSignalsCard({super.key, required this.issueId});

  Color _getSeverityColor(String severity) {
    switch (severity.toUpperCase()) {
      case 'CRITICAL':
        return AppTheme.statusRed;
      case 'HIGH':
        return AppTheme.statusAmber;
      case 'MEDIUM':
        return const Color(0xFFF59E0B);
      default:
        return AppTheme.textMuted;
    }
  }

  IconData _getRiskIcon(String riskType) {
    switch (riskType) {
      case 'SLA_PROXIMITY':
        return Icons.timer_off_outlined;
      case 'IDLE_UNASSIGNED':
        return Icons.person_off_outlined;
      case 'BLOCKED_SUBTASKS':
        return Icons.checklist_rtl_outlined;
      case 'HIGH_PRIORITY_STALLED':
        return Icons.warning_amber_rounded;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final slaProvider = context.watch<SlaProvider>();
    final risks = slaProvider.risks.where((r) => r.active).toList();

    if (risks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB), // Warm warning light amber
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCD34D), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, color: Color(0xFFD97706), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Active Operational Risks (${risks.length})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF92400E),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFFDE68A)),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: risks.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFFDE68A)),
            itemBuilder: (context, index) {
              final risk = risks[index];
              final sevColor = _getSeverityColor(risk.severity);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(_getRiskIcon(risk.riskType), size: 18, color: sevColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                risk.riskType.replaceAll('_', ' '),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: sevColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: sevColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  risk.severity,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: sevColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            risk.explanation,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF78350F),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
