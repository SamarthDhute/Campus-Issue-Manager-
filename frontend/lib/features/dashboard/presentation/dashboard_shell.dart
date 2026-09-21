import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_campus_issue_manager/core/constants/app_constants.dart';
import 'package:smart_campus_issue_manager/core/theme/app_theme.dart';
import 'package:smart_campus_issue_manager/features/auth/data/models/auth_user_model.dart';
import 'package:smart_campus_issue_manager/features/auth/state/auth_provider.dart';
import 'package:smart_campus_issue_manager/features/profile/presentation/profile_screen.dart';
import 'package:smart_campus_issue_manager/features/sla/presentation/widgets/notifications_drawer.dart';
import 'package:smart_campus_issue_manager/features/analytics/presentation/screens/analytics_dashboard_view.dart';
import 'views/lead_dashboard_view.dart';
import 'views/manager_dashboard_view.dart';
import 'views/operator_dashboard_view.dart';
import 'views/student_dashboard_view.dart';
import 'widgets/role_badge.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _currentIndex = 0;

  Widget _buildRoleHome(String role) {
    switch (role.toUpperCase()) {
      case AppConstants.roleOperator:
        return const OperatorDashboardView();
      case AppConstants.roleTeamLead:
        return const LeadDashboardView();
      case AppConstants.roleManager:
      case AppConstants.roleAdmin:
        return const ManagerDashboardView();
      case AppConstants.roleStudent:
      default:
        return const StudentDashboardView();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user ??
        AuthUserModel(
          id: 'demo-student-id',
          email: 'student@smartcampus.edu',
          displayName: 'Aarav Sharma',
          role: 'STUDENT',
          organizationName: 'Smart Campus University',
          teams: ['Hostel Block B'],
        );

    final canViewAnalytics = user.role.toUpperCase() != AppConstants.roleStudent;

    final pages = [
      _buildRoleHome(user.role),
      if (canViewAnalytics) const AnalyticsDashboardView(),
      const ProfileScreen(),
    ];

    return Scaffold(
      endDrawer: const NotificationsDrawer(),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.school_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Smart Campus',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
        actions: [
          const NotificationBellAction(),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: RoleBadge(role: user.role),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppTheme.textMuted),
            tooltip: 'Sign Out',
            onPressed: () => _confirmLogout(context),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppTheme.borderSubtle, height: 1),
        ),
      ),
      body: pages[_currentIndex.clamp(0, pages.length - 1)],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex.clamp(0, pages.length - 1),
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: AppTheme.surfaceWhite,
          indicatorColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded, color: AppTheme.primaryBlue),
              label: 'Workspace',
            ),
            if (canViewAnalytics)
              const NavigationDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics_rounded, color: AppTheme.primaryBlue),
                label: 'Analytics',
              ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded, color: AppTheme.primaryBlue),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out from your campus session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthProvider>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
