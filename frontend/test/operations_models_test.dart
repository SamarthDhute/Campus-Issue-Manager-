import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus_issue_manager/features/operations/data/models/operation_models.dart';

void main() {
  group('Smart Operations Models Unit Tests', () {
    test('AssignmentModel should parse from JSON properly', () {
      final json = {
        'id': 'asg-1',
        'issueId': 'iss-1',
        'teamId': 'tm-1',
        'teamName': 'Plumbing Services',
        'userId': 'usr-1',
        'userName': 'Vikram Singh',
        'userEmail': 'operator@smartcampus.edu',
        'assignmentType': 'PRIMARY',
        'recommendationSource': 'AI_RECOMMENDED',
        'reason': 'Specialist match',
        'assignedByName': 'Priya Patel',
        'assignedAt': '2026-09-17T10:00:00.000Z',
        'endedAt': null,
        'active': true,
      };

      final model = AssignmentModel.fromJson(json);

      expect(model.id, 'asg-1');
      expect(model.teamName, 'Plumbing Services');
      expect(model.userName, 'Vikram Singh');
      expect(model.active, true);
      expect(model.recommendationSource, 'AI_RECOMMENDED');
    });

    test('AssignmentRecommendationModel should parse candidates properly', () {
      final json = {
        'issueId': 'iss-1',
        'recommendedTeamId': 'tm-1',
        'recommendedTeamName': 'Plumbing Services',
        'recommendedUserId': 'usr-1',
        'recommendedUserName': 'Vikram Singh',
        'recommendedUserEmail': 'operator@smartcampus.edu',
        'matchScore': 0.95,
        'rationale': 'Domain specialist with low queue load',
        'currentActiveWorkload': 2,
        'alternateCandidates': [
          {
            'userId': 'usr-2',
            'name': 'Rahul Verma',
            'email': 'rahul@smartcampus.edu',
            'teamName': 'General Maintenance',
            'activeTasksCount': 5,
            'matchScore': 0.80,
            'reason': 'Backup technician',
          }
        ],
      };

      final rec = AssignmentRecommendationModel.fromJson(json);

      expect(rec.recommendedUserName, 'Vikram Singh');
      expect(rec.matchScore, 0.95);
      expect(rec.currentActiveWorkload, 2);
      expect(rec.alternateCandidates.length, 1);
      expect(rec.alternateCandidates[0].name, 'Rahul Verma');
    });

    test('IssueMessageModel should parse chat message properly', () {
      final json = {
        'id': 'msg-1',
        'issueId': 'iss-1',
        'senderId': 'usr-1',
        'senderName': 'Aarav Sharma',
        'senderRole': 'STUDENT',
        'messageType': 'USER_MESSAGE',
        'body': 'Water dripping started around 7 AM',
        'visibility': 'PUBLIC',
        'createdAt': '2026-09-17T08:00:00.000Z',
      };

      final msg = IssueMessageModel.fromJson(json);

      expect(msg.id, 'msg-1');
      expect(msg.senderName, 'Aarav Sharma');
      expect(msg.body, 'Water dripping started around 7 AM');
      expect(msg.visibility, 'PUBLIC');
    });

    test('InternalNoteModel should parse private staff note properly', () {
      final json = {
        'id': 'note-1',
        'issueId': 'iss-1',
        'authorId': 'usr-lead',
        'authorName': 'Priya Patel',
        'authorRole': 'TEAM_LEAD',
        'body': 'Require supervisor approval for rubber seal requisition',
        'createdAt': '2026-09-17T09:00:00.000Z',
      };

      final note = InternalNoteModel.fromJson(json);

      expect(note.id, 'note-1');
      expect(note.authorRole, 'TEAM_LEAD');
      expect(note.body, contains('rubber seal requisition'));
    });

    test('InvestigationModel should parse field report properly', () {
      final json = {
        'id': 'inv-1',
        'issueId': 'iss-1',
        'investigatorId': 'usr-op',
        'investigatorName': 'Vikram Singh',
        'investigatorRole': 'OPERATOR',
        'observations': 'Water seepage near 2-inch PVC junction',
        'actionsTaken': 'Applied temporary epoxy seal',
        'findings': 'Coupling thread slippage due to vibration',
        'followUp': 'Replace with brass sleeve during weekend',
        'createdAt': '2026-09-17T11:00:00.000Z',
      };

      final inv = InvestigationModel.fromJson(json);

      expect(inv.id, 'inv-1');
      expect(inv.investigatorName, 'Vikram Singh');
      expect(inv.findings, contains('Coupling thread slippage'));
      expect(inv.actionsTaken, contains('epoxy seal'));
    });

    test('IssueTaskModel should parse task and track completion', () {
      final jsonPending = {
        'id': 'tsk-1',
        'issueId': 'iss-1',
        'title': 'Isolate riser valve',
        'description': 'Close valve 4 in riser closet',
        'ownerName': 'Vikram Singh',
        'status': 'PENDING',
      };

      final taskPending = IssueTaskModel.fromJson(jsonPending);
      expect(taskPending.title, 'Isolate riser valve');
      expect(taskPending.isCompleted, false);

      final jsonCompleted = {
        'id': 'tsk-2',
        'issueId': 'iss-1',
        'title': 'Pressure check',
        'status': 'COMPLETED',
        'completedAt': '2026-09-17T12:00:00.000Z',
      };

      final taskCompleted = IssueTaskModel.fromJson(jsonCompleted);
      expect(taskCompleted.isCompleted, true);
    });
  });
}
