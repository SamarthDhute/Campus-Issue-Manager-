import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus_issue_manager/features/issues/data/models/category_model.dart';
import 'package:smart_campus_issue_manager/features/issues/data/models/issue_model.dart';
import 'package:smart_campus_issue_manager/features/issues/data/models/timeline_event_model.dart';

void main() {
  group('Issue Models Unit Tests', () {
    test('CategoryModel should correctly parse from JSON', () {
      final json = {
        'id': 'cat-1',
        'name': 'Electrical Services',
        'description': 'Power cuts, switches, lighting',
        'active': true,
      };

      final model = CategoryModel.fromJson(json);

      expect(model.id, 'cat-1');
      expect(model.name, 'Electrical Services');
      expect(model.description, 'Power cuts, switches, lighting');
      expect(model.active, true);
    });

    test('TimelineEventModel should correctly parse from JSON', () {
      final json = {
        'id': 'tl-1',
        'eventType': 'STATUS_CHANGED',
        'actorId': 'usr-1',
        'actorName': 'Alex Tech',
        'actorRole': 'OPERATOR',
        'description': 'Status changed from REPORTED to INVESTIGATING',
        'createdAt': '2026-09-17T10:00:00.000Z',
      };

      final model = TimelineEventModel.fromJson(json);

      expect(model.id, 'tl-1');
      expect(model.eventType, 'STATUS_CHANGED');
      expect(model.actorName, 'Alex Tech');
      expect(model.actorRole, 'OPERATOR');
    });

    test('IssueModel should parse and serialize correctly', () {
      final json = {
        'id': 'iss-1',
        'issueNumber': 'ISS-2026-0001',
        'title': 'AC not cooling in Room 302',
        'description': 'Air conditioner blower is running but not cooling.',
        'categoryId': 'cat-1',
        'categoryName': 'Electrical & HVAC',
        'location': 'Hostel Block B, Room 302',
        'requesterId': 'req-1',
        'requesterName': 'Samarth Student',
        'requesterEmail': 'student@smartcampus.edu',
        'assignedTeamId': 'team-1',
        'assignedTeamName': 'HVAC Team',
        'assignedUserId': 'usr-2',
        'assignedUserName': 'John Operator',
        'status': 'INVESTIGATING',
        'priority': 'HIGH',
        'timeline': [
          {
            'id': 'tl-1',
            'eventType': 'REPORTED',
            'actorName': 'Samarth Student',
            'actorRole': 'STUDENT',
            'description': 'Issue created',
            'createdAt': '2026-09-17T09:00:00.000Z',
          }
        ],
        'createdAt': '2026-09-17T09:00:00.000Z',
        'updatedAt': '2026-09-17T09:30:00.000Z',
      };

      final issue = IssueModel.fromJson(json);

      expect(issue.id, 'iss-1');
      expect(issue.issueNumber, 'ISS-2026-0001');
      expect(issue.title, 'AC not cooling in Room 302');
      expect(issue.status, 'INVESTIGATING');
      expect(issue.priority, 'HIGH');
      expect(issue.timeline.length, 1);
      expect(issue.timeline[0].actorRole, 'STUDENT');

      final serialized = issue.toJson();
      expect(serialized['id'], 'iss-1');
      expect(serialized['issueNumber'], 'ISS-2026-0001');
      expect(serialized['status'], 'INVESTIGATING');
    });
  });
}
