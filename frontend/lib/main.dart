import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/state/auth_provider.dart';
import 'features/dashboard/presentation/dashboard_shell.dart';
import 'features/profile/state/profile_provider.dart';

import 'features/issues/state/category_provider.dart';
import 'features/issues/state/issue_provider.dart';
import 'features/issues/state/ai_provider.dart';
import 'features/operations/state/operations_provider.dart';
import 'features/sla/presentation/state/sla_provider.dart';
import 'features/sla/presentation/state/notification_provider.dart';
import 'features/resolution/state/resolution_provider.dart';
import 'features/analytics/state/analytics_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuthStatus()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => IssueProvider()),
        ChangeNotifierProvider(create: (_) => AiProvider()),
        ChangeNotifierProvider(create: (_) => OperationsProvider()),
        ChangeNotifierProvider(create: (_) => SlaProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()..startPolling()),
        ChangeNotifierProvider(create: (_) => ResolutionProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
      ],
      child: const SmartCampusApp(),
    ),
  );
}

class SmartCampusApp extends StatelessWidget {
  const SmartCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppRootGate(),
    );
  }
}

class AppRootGate extends StatelessWidget {
  const AppRootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isAuthenticated) {
      return const DashboardShell();
    }

    return const LoginScreen();
  }
}
