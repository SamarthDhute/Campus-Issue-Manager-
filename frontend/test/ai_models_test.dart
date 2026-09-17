import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus_issue_manager/features/issues/data/models/ai_models.dart';

void main() {
  group('AI Case Intelligence Models Unit Tests', () {
    test('AiRecommendationModel should correctly parse from JSON', () {
      final json = {
        'id': 'rec-1',
        'analysisId': 'ai-1',
        'issueId': 'iss-1',
        'recommendationType': 'PRIORITY',
        'suggestedValue': 'HIGH',
        'confidence': 0.94,
        'explanation': 'Active water leakage hazard',
        'decision': 'ACCEPTED',
        'decidedById': 'usr-1',
        'decidedByName': 'Vikram Singh',
        'decidedAt': '2026-09-17T10:00:00.000Z',
        'createdAt': '2026-09-17T09:55:00.000Z',
      };

      final rec = AiRecommendationModel.fromJson(json);

      expect(rec.id, 'rec-1');
      expect(rec.recommendationType, 'PRIORITY');
      expect(rec.suggestedValue, 'HIGH');
      expect(rec.confidence, 0.94);
      expect(rec.decision, 'ACCEPTED');
      expect(rec.decidedByName, 'Vikram Singh');
    });

    test('AiAnalysisModel should parse nested recommendations correctly', () {
      final json = {
        'id': 'ai-1',
        'issueId': 'iss-1',
        'issueNumber': 'ISS-2026-0001',
        'status': 'COMPLETED',
        'model': 'gemini-1.5-flash',
        'summary': 'Water leakage reported on second floor ceiling',
        'missingInformation': 'None',
        'confidence': 0.92,
        'recommendations': [
          {
            'id': 'rec-1',
            'recommendationType': 'PRIORITY',
            'suggestedValue': 'HIGH',
            'confidence': 0.94,
            'explanation': 'Active leak hazard',
            'decision': 'PENDING',
          },
          {
            'id': 'rec-2',
            'recommendationType': 'NEXT_ACTION',
            'suggestedValue': 'Dispatch plumbing technician with pipe valve key',
            'confidence': 0.90,
            'explanation': 'Immediate isolation required',
            'decision': 'PENDING',
          }
        ],
        'createdAt': '2026-09-17T09:55:00.000Z',
        'completedAt': '2026-09-17T09:55:05.000Z',
      };

      final analysis = AiAnalysisModel.fromJson(json);

      expect(analysis.id, 'ai-1');
      expect(analysis.issueNumber, 'ISS-2026-0001');
      expect(analysis.model, 'gemini-1.5-flash');
      expect(analysis.confidence, 0.92);
      expect(analysis.recommendations.length, 2);
      expect(analysis.recommendations[0].suggestedValue, 'HIGH');
      expect(analysis.recommendations[1].recommendationType, 'NEXT_ACTION');
    });

    test('RelatedIssueModel should parse duplicate candidate correctly', () {
      final json = {
        'relationshipId': 'rel-1',
        'issueId': 'iss-2',
        'issueNumber': 'ISS-2026-0002',
        'title': 'Water leaking near Room 204',
        'location': 'Hostel Block B',
        'categoryName': 'Water & Plumbing',
        'status': 'REPORTED',
        'priority': 'MEDIUM',
        'relationshipType': 'DUPLICATE_CANDIDATE',
        'confidence': 0.88,
        'explanation': 'Same location and category reported within 24h',
        'createdAt': '2026-09-17T10:00:00.000Z',
      };

      final related = RelatedIssueModel.fromJson(json);

      expect(related.relationshipId, 'rel-1');
      expect(related.issueNumber, 'ISS-2026-0002');
      expect(related.relationshipType, 'DUPLICATE_CANDIDATE');
      expect(related.confidence, 0.88);
    });
  });
}
