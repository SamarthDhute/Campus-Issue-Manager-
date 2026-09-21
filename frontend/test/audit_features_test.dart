import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus_issue_manager/features/audit/data/models/audit_models.dart';
import 'package:smart_campus_issue_manager/features/audit/presentation/widgets/audit_trail_widget.dart';
import 'package:smart_campus_issue_manager/features/audit/presentation/widgets/system_status_banner.dart';

void main() {
  group('Phase 8 Audit & Trust Models Test Suite', () {
    test('AuditEventModel deserializes correctly from JSON', () {
      final json = {
        'id': 'audit-1234',
        'actorId': 'user-1',
        'actorName': 'Dr. Suresh Mehta',
        'actorRole': 'MANAGER',
        'entityType': 'ISSUE',
        'entityId': 'issue-99',
        'eventType': 'STATUS_CHANGED',
        'actionSummary': 'Status changed from REPORTED to INVESTIGATING',
        'beforeData': '{"status":"REPORTED"}',
        'afterData': '{"status":"INVESTIGATING"}',
        'metadata': '{"comment":"Urgent check needed"}',
        'ipAddress': '192.168.1.1',
        'createdAt': '2026-09-21T18:00:00Z',
      };

      final model = AuditEventModel.fromJson(json);

      expect(model.id, 'audit-1234');
      expect(model.actorName, 'Dr. Suresh Mehta');
      expect(model.actorRole, 'MANAGER');
      expect(model.eventType, 'STATUS_CHANGED');
      expect(model.actionSummary, 'Status changed from REPORTED to INVESTIGATING');
      expect(model.beforeData, '{"status":"REPORTED"}');
      expect(model.afterData, '{"status":"INVESTIGATING"}');
    });

    test('SecurityEventModel & SystemStatusModel deserialize correctly', () {
      final secJson = {
        'id': 'sec-001',
        'actorEmail': 'suspicious@domain.com',
        'eventType': 'LOGIN_FAILED',
        'severity': 'WARNING',
        'metadata': '{"attempts": 3}',
        'createdAt': '2026-09-21T18:00:00Z',
      };

      final secModel = SecurityEventModel.fromJson(secJson);
      expect(secModel.id, 'sec-001');
      expect(secModel.eventType, 'LOGIN_FAILED');
      expect(secModel.severity, 'WARNING');

      final statusJson = {
        'status': 'UP',
        'environment': 'production-ready',
        'version': '1.0.0',
        'uptimeSeconds': 7200,
        'serverTime': '2026-09-21T18:00:00Z',
        'components': {
          'database': {'status': 'UP', 'details': 'PostgreSQL Supabase Connected'},
          'aiEngine': {'status': 'UP', 'mode': 'GEMINI_1_5_FLASH'},
          'storage': {'status': 'UP'},
          'scheduler': {'status': 'UP'}
        },
        'metrics': {
          'usedMemoryMb': 150,
          'activeThreads': 18
        }
      };

      final statusModel = SystemStatusModel.fromJson(statusJson);
      expect(statusModel.status, 'UP');
      expect(statusModel.version, '1.0.0');
      expect(statusModel.components['database']['status'], 'UP');
      expect(statusModel.metrics['usedMemoryMb'], 150);
    });
  });

  group('Phase 8 Presentation Widgets Test Suite', () {
    testWidgets('AuditTrailWidget renders empty state and list items correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuditTrailWidget(events: []),
          ),
        ),
      );

      expect(find.text('No audit events recorded yet.'), findsOneWidget);

      final events = [
        AuditEventModel(
          id: '1',
          actorName: 'Priya Patel',
          actorRole: 'TEAM_LEAD',
          entityType: 'ISSUE',
          entityId: 'issue-1',
          eventType: 'AI_DECISION_OVERRIDDEN',
          actionSummary: 'Team lead overrode AI priority recommendation',
          beforeData: '{"priority":"LOW"}',
          afterData: '{"priority":"HIGH"}',
          createdAt: DateTime(2026, 9, 21, 14, 30),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AuditTrailWidget(events: events),
            ),
          ),
        ),
      );

      expect(find.text('AI DECISION OVERRIDDEN'), findsOneWidget);
      expect(find.text('Team lead overrode AI priority recommendation'), findsOneWidget);
      expect(find.text('Priya Patel (TEAM_LEAD)'), findsOneWidget);
      expect(find.text('Before: {"priority":"LOW"}'), findsOneWidget);
      expect(find.text('After: {"priority":"HIGH"}'), findsOneWidget);
    });

    testWidgets('SystemStatusBanner renders production diagnostic chips', (tester) async {
      final statusModel = SystemStatusModel(
        status: 'UP',
        environment: 'production',
        version: '1.0.0',
        uptimeSeconds: 3600,
        serverTime: DateTime.now(),
        components: {
          'database': {'status': 'UP'},
          'aiEngine': {'status': 'UP'},
          'storage': {'status': 'UP'},
          'scheduler': {'status': 'UP'}
        },
        metrics: {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SystemStatusBanner(status: statusModel),
          ),
        ),
      );

      expect(find.text('System Production Diagnostics: UP'), findsOneWidget);
      expect(find.text('Database: Online'), findsOneWidget);
      expect(find.text('AI Engine: Online'), findsOneWidget);
      expect(find.text('Storage: Online'), findsOneWidget);
      expect(find.text('SLA Scheduler: Online'), findsOneWidget);
    });
  });
}
