import 'package:smart_campus_issue_manager/core/network/api_client.dart';
import '../models/ai_models.dart';

class AiRepository {
  final ApiClient _apiClient;

  AiRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<AiAnalysisModel> getAnalysis(String issueId) async {
    final response = await _apiClient.get('/issues/$issueId/ai');
    return AiAnalysisModel.fromJson(response as Map<String, dynamic>);
  }

  Future<AiAnalysisModel> triggerAnalysis(String issueId) async {
    final response = await _apiClient.post('/issues/$issueId/ai/analyze', {});
    return AiAnalysisModel.fromJson(response as Map<String, dynamic>);
  }

  Future<AiRecommendationModel> recordDecision(
    String issueId,
    String recommendationId,
    String decision, {
    String? overrideValue,
    String? comments,
  }) async {
    final response = await _apiClient.post(
      '/issues/$issueId/ai/recommendations/$recommendationId/decision',
      {
        'decision': decision,
        if (overrideValue != null) 'overrideValue': overrideValue,
        if (comments != null) 'comments': comments,
      },
    );
    return AiRecommendationModel.fromJson(response as Map<String, dynamic>);
  }

  Future<List<RelatedIssueModel>> getRelatedIssues(String issueId) async {
    final response = await _apiClient.get('/issues/$issueId/related');
    if (response is List) {
      return response.map((e) => RelatedIssueModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
