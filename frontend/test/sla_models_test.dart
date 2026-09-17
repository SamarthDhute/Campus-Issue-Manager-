import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus_issue_manager/features/sla/data/models/sla_models.dart';

void main() {
  group('SLA & Automation Models Unit Tests', () {
    test('IssueSlaModel should parse JSON correctly with milestones', () {
      final json = {
        'id': 'sla-1',
        'issueId': 'iss-1',
        'responseDueAt': '2026-09-17T11:00:00.000Z',
        'resolutionDueAt': '2026-09-17T18:00:00.000Z',
        'responseMetAt': '2026-09-17T10:15:00.000Z',
        'resolutionMetAt': null,
        'responseBreachedAt': null,
        'resolutionBreachedAt': null,
        'status': 'ON_TRACK',
        'responseSecondsRemaining': 0,
        'resolutionSecondsRemaining': 25200,
        'responseProgressPercentage': 100.0,
        'resolutionProgressPercentage': 12.5,
        'responseBreached': false,
        'resolutionBreached': false,
        'responseMet': true,
        'resolutionMet': false,
      };

      final sla = IssueSlaModel.fromJson(json);

      expect(sla.id, 'sla-1');
      expect(sla.status, 'ON_TRACK');
      expect(sla.responseMet, true);
      expect(sla.resolutionMet, false);
      expect(sla.resolutionSecondsRemaining, 25200);
      expect(sla.responseProgressPercentage, 100.0);
    });

    test('RiskEventModel should parse risk explanation and severity', () {
      final json = {
        'id': 'risk-1',
        'issueId': 'iss-1',
        'riskType': 'SLA_PROXIMITY',
        'severity': 'HIGH',
        'explanation': 'Resolution SLA approaching breach: only 25 minutes remaining.',
        'detectedAt': '2026-09-17T17:35:00.000Z',
        'resolvedAt': null,
        'active': true,
      };

      final risk = RiskEventModel.fromJson(json);

      expect(risk.id, 'risk-1');
      expect(risk.riskType, 'SLA_PROXIMITY');
      expect(risk.severity, 'HIGH');
      expect(risk.active, true);
      expect(risk.explanation, contains('25 minutes remaining'));
    });

    test('EscalationModel should parse escalation tiers and actor properly', () {
      final json = {
        'id': 'esc-1',
        'issueId': 'iss-1',
        'triggerType': 'MANUAL_STAFF_OVERRIDE',
        'level': 2,
        'status': 'OPEN',
        'reason': 'Major infrastructure failure requiring campus manager review',
        'triggeredById': 'usr-lead',
        'triggeredByName': 'Priya Patel',
        'triggeredByRole': 'TEAM_LEAD',
        'triggeredAt': '2026-09-17T12:00:00.000Z',
        'resolvedAt': null,
      };

      final esc = EscalationModel.fromJson(json);

      expect(esc.id, 'esc-1');
      expect(esc.level, 2);
      expect(esc.status, 'OPEN');
      expect(esc.triggeredByName, 'Priya Patel');
      expect(esc.triggeredByRole, 'TEAM_LEAD');
    });

    test('NotificationModel should parse in-app alert and unread flag', () {
      final json = {
        'id': 'notif-1',
        'recipientId': 'usr-student',
        'issueId': 'iss-1',
        'issueNumber': 'ISS-2026-0001',
        'notificationType': 'SLA_WARNING',
        'title': '⏳ SLA Warning: ISS-2026-0001',
        'body': 'Less than 25% resolution time remains for your reported issue.',
        'channel': 'IN_APP',
        'status': 'UNREAD',
        'sentAt': '2026-09-17T14:00:00.000Z',
        'readAt': null,
        'createdAt': '2026-09-17T14:00:00.000Z',
      };

      final notif = NotificationModel.fromJson(json);

      expect(notif.id, 'notif-1');
      expect(notif.isUnread, true);
      expect(notif.issueNumber, 'ISS-2026-0001');
      expect(notif.notificationType, 'SLA_WARNING');
    });
  });
}
