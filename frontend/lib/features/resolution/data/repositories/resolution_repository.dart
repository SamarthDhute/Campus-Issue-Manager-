import 'package:smart_campus_issue_manager/core/network/api_client.dart';
import '../models/evidence_model.dart';
import '../models/feedback_model.dart';

class ResolutionRepository {
  final ApiClient _apiClient;

  ResolutionRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<EvidenceModel> uploadEvidence({
    required String issueId,
    required EvidenceType evidenceType,
    required String fileUrl,
    required String fileName,
    int? fileSize,
    String? mimeType,
    String? notes,
  }) async {
    final response = await _apiClient.post('/issues/$issueId/evidence', {
      'evidenceType': evidenceType.value,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'notes': notes,
    });
    return EvidenceModel.fromJson(response as Map<String, dynamic>);
  }

  Future<List<EvidenceModel>> getEvidence(String issueId, {EvidenceType? type}) async {
    final query = type != null ? '?type=${type.value}' : '';
    final response = await _apiClient.get('/issues/$issueId/evidence$query');
    if (response is List) {
      return response.map((item) => EvidenceModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<FeedbackModel> submitFeedback({
    required String issueId,
    required int rating,
    String? feedbackText,
    ResolutionQuality resolutionQuality = ResolutionQuality.satisfied,
  }) async {
    final response = await _apiClient.post('/issues/$issueId/feedback', {
      'rating': rating,
      'feedbackText': feedbackText,
      'resolutionQuality': resolutionQuality.value,
    });
    return FeedbackModel.fromJson(response as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> reopenIssue({
    required String issueId,
    required String reason,
  }) async {
    final response = await _apiClient.post('/issues/$issueId/reopen', {
      'reason': reason,
    });
    return response as Map<String, dynamic>;
  }

  Future<FeedbackModel?> getFeedback(String issueId) async {
    final response = await _apiClient.get('/issues/$issueId/feedback');
    if (response != null && response is Map<String, dynamic>) {
      return FeedbackModel.fromJson(response);
    }
    return null;
  }
}
