import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus_issue_manager/features/issues/data/models/issue_model.dart';
import 'package:smart_campus_issue_manager/features/issues/presentation/widgets/issue_card.dart';
import 'package:smart_campus_issue_manager/features/issues/presentation/widgets/priority_chip.dart';
import 'package:smart_campus_issue_manager/features/issues/presentation/widgets/status_chip.dart';

void main() {
  group('Issue Widgets Tests', () {
    testWidgets('PriorityChip renders correct text and styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PriorityChip(priority: 'CRITICAL'),
          ),
        ),
      );

      expect(find.text('CRITICAL'), findsOneWidget);
    });

    testWidgets('StatusChip renders formatted status label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusChip(status: 'INVESTIGATING'),
          ),
        ),
      );

      expect(find.text('INVESTIGATING'), findsOneWidget);
    });

    testWidgets('IssueCard renders issue summary and responds to tap', (tester) async {
      bool tapped = false;
      final sampleIssue = IssueModel(
        id: 'iss-test',
        issueNumber: 'ISS-2026-0099',
        title: 'Water leakage in corridor',
        description: 'Main pipe leaking water near lab 101.',
        location: 'Engineering Block A, 1st Floor',
        requesterId: 'user-1',
        requesterName: 'Student User',
        status: 'REPORTED',
        priority: 'MEDIUM',
        timeline: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IssueCard(
              issue: sampleIssue,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('ISS-2026-0099'), findsOneWidget);
      expect(find.text('Water leakage in corridor'), findsOneWidget);
      expect(find.text('Engineering Block A, 1st Floor'), findsOneWidget);

      await tester.tap(find.byType(IssueCard));
      expect(tapped, isTrue);
    });
  });
}
