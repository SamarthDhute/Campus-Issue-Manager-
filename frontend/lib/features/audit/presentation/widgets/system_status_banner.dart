import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/audit_models.dart';

class SystemStatusBanner extends StatelessWidget {
  final SystemStatusModel? status;
  final VoidCallback? onRefresh;

  const SystemStatusBanner({Key? key, this.status, this.onRefresh}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (status == null) {
      return const SizedBox.shrink();
    }

    final isUp = status!.status.toUpperCase() == 'UP';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUp ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUp ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: isUp ? AppTheme.statusGreen : AppTheme.statusRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'System Production Diagnostics: ${status!.status}',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: isUp ? const Color(0xFF166534) : const Color(0xFF991B1B),
                    ),
                  ),
                ],
              ),
              if (onRefresh != null)
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  onPressed: onRefresh,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: AppTheme.textMuted,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              _buildComponentChip('Database', status!.components['database']),
              _buildComponentChip('AI Engine', status!.components['aiEngine']),
              _buildComponentChip('Storage', status!.components['storage']),
              _buildComponentChip('SLA Scheduler', status!.components['scheduler']),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComponentChip(String label, dynamic component) {
    final isCompUp = component is Map && component['status'] == 'UP';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isCompUp ? Icons.check_circle : Icons.error,
          size: 14,
          color: isCompUp ? AppTheme.statusGreen : AppTheme.statusRed,
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ${isCompUp ? "Online" : "Degraded"}',
          style: const TextStyle(fontSize: 11.5, color: AppTheme.textDark, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
