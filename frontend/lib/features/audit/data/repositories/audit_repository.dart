import 'package:smart_campus_issue_manager/core/network/api_client.dart';
import '../models/audit_models.dart';

class AuditRepository {
  final ApiClient _apiClient;

  AuditRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<AuditEventModel>> getIssueAuditTrail(String issueId) async {
    final response = await _apiClient.get('/issues/$issueId/audit');
    if (response is List) {
      return response.map((e) => AuditEventModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<AuditEventModel>> getSystemAuditLogs({
    String? entityType,
    String? eventType,
    String? actorId,
  }) async {
    final queryParams = <String>[];
    if (entityType != null) queryParams.add('entityType=$entityType');
    if (eventType != null) queryParams.add('eventType=$eventType');
    if (actorId != null) queryParams.add('actorId=$actorId');

    final query = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
    final response = await _apiClient.get('/admin/audit$query');

    if (response is Map<String, dynamic> && response.containsKey('content')) {
      final list = response['content'] as List;
      return list.map((e) => AuditEventModel.fromJson(e as Map<String, dynamic>)).toList();
    } else if (response is List) {
      return response.map((e) => AuditEventModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<SecurityEventModel>> getSecurityLogs({
    String? severity,
    String? eventType,
  }) async {
    final queryParams = <String>[];
    if (severity != null) queryParams.add('severity=$severity');
    if (eventType != null) queryParams.add('eventType=$eventType');

    final query = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
    final response = await _apiClient.get('/admin/security-logs$query');

    if (response is Map<String, dynamic> && response.containsKey('content')) {
      final list = response['content'] as List;
      return list.map((e) => SecurityEventModel.fromJson(e as Map<String, dynamic>)).toList();
    } else if (response is List) {
      return response.map((e) => SecurityEventModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<SystemStatusModel> getSystemStatus() async {
    final response = await _apiClient.get('/system/status');
    return SystemStatusModel.fromJson(response as Map<String, dynamic>);
  }
}
