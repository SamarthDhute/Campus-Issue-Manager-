import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

class RoleBadge extends StatelessWidget {
  final String role;

  const RoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String display;

    switch (role.toUpperCase()) {
      case AppConstants.roleAdmin:
        bg = const Color(0xFF7C3AED).withValues(alpha: 0.12);
        fg = const Color(0xFF6D28D9);
        display = 'Administrator';
        break;
      case AppConstants.roleManager:
        bg = const Color(0xFF0284C7).withValues(alpha: 0.12);
        fg = const Color(0xFF0369A1);
        display = 'Campus Manager';
        break;
      case AppConstants.roleTeamLead:
        bg = const Color(0xFFD97706).withValues(alpha: 0.12);
        fg = const Color(0xFFB45309);
        display = 'Team Lead';
        break;
      case AppConstants.roleOperator:
        bg = AppTheme.primaryIndigo.withValues(alpha: 0.12);
        fg = AppTheme.primaryBlue;
        display = 'Case Operator';
        break;
      case AppConstants.roleStudent:
      default:
        bg = AppTheme.statusGreen.withValues(alpha: 0.12);
        fg = const Color(0xFF047857);
        display = 'Student / Requester';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: fg,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            display,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
