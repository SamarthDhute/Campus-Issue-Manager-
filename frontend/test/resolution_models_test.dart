import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus_issue_manager/features/resolution/data/models/attachment_model.dart';
import 'package:smart_campus_issue_manager/features/resolution/data/models/evidence_model.dart';
import 'package:smart_campus_issue_manager/features/resolution/data/models/feedback_model.dart';

void main() {
  group('Resolution & Media Models Unit Tests', () {
    test('AttachmentModel should correctly parse from JSON', () {
      final json = {
        'id': 'att-123',
        'issueId': 'iss-456',
        'messageId': 'msg-789',
        'uploadedByUserId': 'usr-001',
        'uploadedByName': 'Aarav Sharma',
        'fileName': 'broken_tap.jpg',
        'contentType': 'image/jpeg',
        'sizeBytes': 204800,
        'fileUrl': '/api/v1/files/broken_tap.jpg',
        'thumbnailUrl': '/api/v1/files/broken_tap.jpg',
        'createdAt': '2026-09-21T10:00:00Z',
      };

      final model = AttachmentModel.fromJson(json);

      expect(model.id, equals('att-123'));
      expect(model.fileName, equals('broken_tap.jpg'));
      expect(model.sizeBytes, equals(204800));
      expect(model.fileUrl, equals('/api/v1/files/broken_tap.jpg'));
      expect(model.uploadedByName, equals('Aarav Sharma'));
    });

    test('EvidenceModel should correctly parse from JSON with EvidenceType', () {
      final json = {
        'id': 'ev-123',
        'issueId': 'iss-456',
        'uploadedByUserId': 'usr-002',
        'uploadedByName': 'Vikram Singh',
        'evidenceType': 'BEFORE_REPAIR',
        'fileUrl': '/api/v1/files/before.jpg',
        'fileName': 'before.jpg',
        'fileSize': 102400,
        'mimeType': 'image/jpeg',
        'notes': 'Cracked PVC joint',
        'createdAt': '2026-09-21T11:00:00Z',
      };

      final model = EvidenceModel.fromJson(json);

      expect(model.id, equals('ev-123'));
      expect(model.evidenceType, equals(EvidenceType.beforeRepair));
      expect(model.evidenceType.label, equals('Before Repair'));
      expect(model.notes, equals('Cracked PVC joint'));
    });

    test('FeedbackModel should correctly parse from JSON with rating', () {
      final json = {
        'id': 'fb-123',
        'issueId': 'iss-456',
        'submittedByUserId': 'usr-001',
        'submittedByName': 'Aarav Sharma',
        'rating': 5,
        'feedbackText': 'Prompt and clean repair!',
        'resolutionQuality': 'EXCELLENT',
        'createdAt': '2026-09-21T12:00:00Z',
      };

      final model = FeedbackModel.fromJson(json);

      expect(model.id, equals('fb-123'));
      expect(model.rating, equals(5));
      expect(model.resolutionQuality, equals(ResolutionQuality.excellent));
      expect(model.resolutionQuality.label, equals('Excellent'));
      expect(model.feedbackText, equals('Prompt and clean repair!'));
    });
  });
}
