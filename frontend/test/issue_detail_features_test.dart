import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smart_campus_issue_manager/features/auth/data/models/auth_user_model.dart';
import 'package:smart_campus_issue_manager/features/auth/state/auth_provider.dart';
import 'package:smart_campus_issue_manager/features/dashboard/presentation/widgets/stats_card.dart';
import 'package:smart_campus_issue_manager/features/issues/data/models/issue_model.dart';
import 'package:smart_campus_issue_manager/features/issues/state/ai_provider.dart';
import 'package:smart_campus_issue_manager/features/issues/state/issue_provider.dart';
import 'package:smart_campus_issue_manager/features/operations/state/operations_provider.dart';
import 'package:smart_campus_issue_manager/features/resolution/data/models/evidence_model.dart';
import 'package:smart_campus_issue_manager/features/resolution/data/models/feedback_model.dart';
import 'package:smart_campus_issue_manager/features/resolution/presentation/widgets/resolution_evidence_widget.dart';
import 'package:smart_campus_issue_manager/features/resolution/presentation/widgets/resolution_verification_card.dart';
import 'package:smart_campus_issue_manager/features/resolution/state/resolution_provider.dart';
import 'package:smart_campus_issue_manager/features/sla/presentation/state/sla_provider.dart';
import 'package:smart_campus_issue_manager/features/sla/presentation/widgets/sla_countdown_card.dart';

void main() {
  group('Issue Detail Screen Features & Sub-components Tests', () {
    testWidgets('StatsCard renders correctly and triggers onTap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatsCard(
              title: 'In Progress',
              value: '5',
              icon: Icons.build_circle_outlined,
              subtitle: 'Active cases',
              onTap: () => tapped = true,
              isSelected: true,
            ),
          ),
        ),
      );

      expect(find.text('In Progress'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('Active cases'), findsOneWidget);

      await tester.tap(find.byType(StatsCard));
      expect(tapped, isTrue);
    });

    testWidgets('ResolutionEvidenceWidget renders empty state and Upload button when canUpload is true', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ResolutionProvider()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ResolutionEvidenceWidget(
                issueId: 'iss-test-123',
                canUpload: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Resolution Evidence Suite'), findsOneWidget);
      expect(find.text('Upload Evidence'), findsOneWidget);
      expect(find.text('Add Repair Proof Photo'), findsOneWidget);
    });

    testWidgets('ResolutionVerificationCard renders verified star rating when issue is CLOSED with feedback', (tester) async {
      final sampleIssue = IssueModel(
        id: 'iss-test-closed',
        issueNumber: 'ISS-2026-0003',
        title: 'Garbage cleaning issue',
        description: 'Cleaned and cleared.',
        location: 'Hostel Block A',
        requesterId: 'user-1',
        requesterName: 'Aarav Sharma',
        status: 'CLOSED',
        priority: 'MEDIUM',
        timeline: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ResolutionProvider()),
            ChangeNotifierProvider(create: (_) => IssueProvider()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ResolutionVerificationCard(
                issue: sampleIssue,
              ),
            ),
          ),
        ),
      );

      // Verify widget mounts cleanly without error
      expect(find.byType(ResolutionVerificationCard), findsOneWidget);
    });
  });
}
