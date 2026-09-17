import 'package:flutter/material.dart';
import 'package:smart_campus_issue_manager/core/theme/app_theme.dart';

class PriorityChip extends StatelessWidget {
  final String priority;

  const PriorityChip({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (priority.toUpperCase()) {
      case 'URGENT':
      case 'HIGH':
        color = AppTheme.statusRed;
        break;
      case 'MEDIUM':
        color = AppTheme.statusAmber;
        break;
      case 'LOW':
      default:
        color = AppTheme.statusGreen;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.flag_rounded, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          priority.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
