import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smart_campus_issue_manager/core/constants/app_constants.dart';
import 'package:smart_campus_issue_manager/features/auth/presentation/login_screen.dart';
import 'package:smart_campus_issue_manager/features/auth/state/auth_provider.dart';
import 'package:smart_campus_issue_manager/features/profile/state/profile_provider.dart';

void main() {
  testWidgets('LoginScreen smoke test renders branding and form fields', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text('Sign In to Campus Portal'), findsOneWidget);
    expect(find.text('Campus Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
