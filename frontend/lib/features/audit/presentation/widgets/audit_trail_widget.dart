import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/audit_models.dart';

class AuditTrailWidget extends StatelessWidget {
  final List<AuditEventModel> events;

  const AuditTrailWidget({Key? key, required this.events}) : super(key: key);

  Color _getEventColor(String eventType) {
    if (eventType.contains('OVERRIDDEN')) return AppTheme.statusAmber;
    if (eventType.contains('CREATED') || eventType.contains('ACCEPTED')) return AppTheme.statusGreen;
    if (eventType.contains('BREACH') || eventType.contains('FAILED')) return AppTheme.statusRed;
    if (eventType.contains('DISPATCH')) return AppTheme.primaryBlue;
    return AppTheme.primaryIndigo;
  }

  IconData _getEventIcon(String eventType) {
    if (eventType.contains('OVERRIDDEN')) return Icons.gavel_rounded;
    if (eventType.contains('CREATED')) return Icons.add_circle_outline_rounded;
    if (eventType.contains('STATUS')) return Icons.sync_alt_rounded;
    if (eventType.contains('DISPATCH')) return Icons.send_rounded;
    if (eventType.contains('RESOLUTION')) return Icons.verified_rounded;
    return Icons.history_rounded;
  }

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderSubtle),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.shield_outlined, size: 36, color: AppTheme.textMuted),
              SizedBox(height: 8),
              Text(
                'No audit events recorded yet.',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final event = events[index];
        final eventColor = _getEventColor(event.eventType);
        final eventIcon = _getEventIcon(event.eventType);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: eventColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(eventIcon, color: eventColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: eventColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  event.eventType.replaceAll('_', ' '),
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: eventColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatTime(event.createdAt),
                              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          event.actionSummary ?? 'Action performed',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 14, color: AppTheme.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              '${event.actorName} (${event.actorRole})',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (event.beforeData != null || event.afterData != null) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (event.beforeData != null)
                        Text(
                          'Before: ${event.beforeData}',
                          style: const TextStyle(fontSize: 11, color: AppTheme.statusRed, fontFamily: 'monospace'),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      if (event.afterData != null)
                        Text(
                          'After: ${event.afterData}',
                          style: const TextStyle(fontSize: 11, color: AppTheme.statusGreen, fontFamily: 'monospace'),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
