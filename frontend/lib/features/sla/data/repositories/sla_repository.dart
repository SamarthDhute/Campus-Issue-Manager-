import 'package:smart_campus_issue_manager/core/network/api_client.dart';
import '../models/sla_models.dart';

class SlaRepository {
  final ApiClient _apiClient;

  SlaRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // Get SLA State
  Future<IssueSlaModel> getIssueSla(String issueId) async {
    final response = await _apiClient.get('/issues/$issueId/sla');
    return IssueSlaModel.fromJson(response as Map<String, dynamic>);
  }

  // Get Active Risk Signals
  Future<List<RiskEventModel>> getIssueRisks(String issueId) async {
    final response = await _apiClient.get('/issues/$issueId/risks');
    if (response is List) {
      return response.map((e) => RiskEventModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // Get Escalation History
  Future<List<EscalationModel>> getIssueEscalations(String issueId) async {
    final response = await _apiClient.get('/issues/$issueId/escalations');
    if (response is List) {
      return response.map((e) => EscalationModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // Create Manual Escalation
  Future<EscalationModel> createManualEscalation(
    String issueId, {
    required int level,
    required String reason,
  }) async {
    final response = await _apiClient.post('/issues/$issueId/escalations', {
      'level': level,
      'reason': reason,
    });
    return EscalationModel.fromJson(response as Map<String, dynamic>);
  }
}
