import 'package:flutter/material.dart';
import 'package:smart_campus_issue_manager/core/theme/app_theme.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String display;

    switch (status.toUpperCase()) {
      case 'REPORTED':
        bg = AppTheme.primaryIndigo.withValues(alpha: 0.12);
        fg = AppTheme.primaryBlue;
        display = 'Reported';
        break;
      case 'UNDERSTOOD':
        bg = const Color(0xFF0284C7).withValues(alpha: 0.12);
        fg = const Color(0xFF0369A1);
        display = 'Understood';
        break;
      case 'ASSIGNED':
        bg = const Color(0xFF7C3AED).withValues(alpha: 0.12);
        fg = const Color(0xFF6D28D9);
        display = 'Assigned';
        break;
      case 'INVESTIGATED':
      case 'ACTION_TAKEN':
        bg = AppTheme.statusAmber.withValues(alpha: 0.12);
        fg = const Color(0xFFB45309);
        display = status == 'INVESTIGATED' ? 'Investigating' : 'In Progress';
        break;
      case 'RESOLUTION_PROPOSED':
        bg = const Color(0xFF0D9488).withValues(alpha: 0.12);
        fg = const Color(0xFF0F766E);
        display = 'Resolution Proposed';
        break;
      case 'CONFIRMED':
      case 'CLOSED':
        bg = AppTheme.statusGreen.withValues(alpha: 0.12);
        fg = const Color(0xFF047857);
        display = status == 'CONFIRMED' ? 'Confirmed' : 'Closed';
        break;
      case 'ESCALATED':
        bg = AppTheme.statusRed.withValues(alpha: 0.12);
        fg = AppTheme.statusRed;
        display = 'Escalated';
        break;
      case 'WAITING_FOR_INFORMATION':
        bg = const Color(0xFFEA580C).withValues(alpha: 0.12);
        fg = const Color(0xFFC2410C);
        display = 'Waiting Info';
        break;
      default:
        bg = AppTheme.textMuted.withValues(alpha: 0.12);
        fg = AppTheme.textMuted;
        display = status;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        display,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
