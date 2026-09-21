import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/analytics_models.dart';

class OperatorLeaderboardWidget extends StatelessWidget {
  final List<OperatorLeaderboardModel> leaderboard;

  const OperatorLeaderboardWidget({Key? key, required this.leaderboard}) : super(key: key);

  Color _getBadgeColor(String badge) {
    if (badge.contains('Star') || badge.contains('Top')) return const Color(0xFFF59E0B);
    if (badge.contains('Speed') || badge.contains('Fast')) return const Color(0xFF10B981);
    return AppTheme.primaryIndigo;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.emoji_events_outlined, color: Color(0xFFF59E0B), size: 22),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Operational Performance Leaderboard',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${leaderboard.length} Staff',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (leaderboard.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No operator activity records found.',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: leaderboard.length,
              separatorBuilder: (_, __) => const Divider(color: AppTheme.borderSubtle, height: 20),
              itemBuilder: (context, index) {
                final op = leaderboard[index];
                final badgeColor = _getBadgeColor(op.efficiencyBadge);

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 450;
                    if (isCompact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: index == 0
                                      ? const Color(0xFFFEF3C7)
                                      : (index == 1 ? const Color(0xFFF1F5F9) : const Color(0xFFFFEDD5)),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: index == 0
                                        ? const Color(0xFFF59E0B)
                                        : (index == 1 ? const Color(0xFF94A3B8) : const Color(0xFFFB923C)),
                                  ),
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: index == 0
                                        ? const Color(0xFFB45309)
                                        : (index == 1 ? const Color(0xFF475569) : const Color(0xFFC2410C)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  op.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textDark,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: badgeColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  op.efficiencyBadge,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: badgeColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${op.teamName} • ${op.email}',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _StatChip(
                                  label: 'Resolved',
                                  value: '${op.resolvedCount}',
                                  valueColor: AppTheme.statusGreen,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: _StatChip(
                                  label: 'MTTR',
                                  value: '${op.averageResolutionHours.toStringAsFixed(1)}h',
                                  valueColor: AppTheme.primaryIndigo,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: _StatChip(
                                  label: 'SLA',
                                  value: '${op.slaComplianceRate.toStringAsFixed(0)}%',
                                  valueColor: op.slaComplianceRate >= 90
                                      ? AppTheme.statusGreen
                                      : AppTheme.statusAmber,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: index == 0
                                ? const Color(0xFFFEF3C7)
                                : (index == 1
                                    ? const Color(0xFFF1F5F9)
                                    : const Color(0xFFFFEDD5)),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: index == 0
                                  ? const Color(0xFFF59E0B)
                                  : (index == 1 ? const Color(0xFF94A3B8) : const Color(0xFFFB923C)),
                            ),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: index == 0
                                  ? const Color(0xFFB45309)
                                  : (index == 1 ? const Color(0xFF475569) : const Color(0xFFC2410C)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      op.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textDark,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: badgeColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      op.efficiencyBadge,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: badgeColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${op.teamName} • ${op.email}',
                                style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Row(
                          children: [
                            _StatChip(
                              label: 'Resolved',
                              value: '${op.resolvedCount}',
                              valueColor: AppTheme.statusGreen,
                            ),
                            const SizedBox(width: 8),
                            _StatChip(
                              label: 'MTTR',
                              value: '${op.averageResolutionHours.toStringAsFixed(1)}h',
                              valueColor: AppTheme.primaryIndigo,
                            ),
                            const SizedBox(width: 8),
                            _StatChip(
                              label: 'SLA',
                              value: '${op.slaComplianceRate.toStringAsFixed(0)}%',
                              valueColor: op.slaComplianceRate >= 90
                                  ? AppTheme.statusGreen
                                  : AppTheme.statusAmber,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _StatChip({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: valueColor),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 9.5, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}
