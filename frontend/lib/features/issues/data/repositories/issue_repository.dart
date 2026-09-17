import 'package:smart_campus_issue_manager/core/network/api_client.dart';
import '../models/issue_model.dart';
import '../models/timeline_event_model.dart';

class IssueRepository {
  final ApiClient _apiClient;

  IssueRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<IssueModel> createIssue({
    required String title,
    required String description,
    required String categoryId,
    required String location,
    required String priority,
  }) async {
    final response = await _apiClient.post('/issues', {
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'location': location,
      'priority': priority,
    });
    return IssueModel.fromJson(response as Map<String, dynamic>);
  }

  Future<List<IssueModel>> getIssues({
    String? status,
    String? categoryId,
    bool? myIssues,
    bool? assignedToMe,
  }) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (categoryId != null) queryParams['categoryId'] = categoryId;
    if (myIssues != null) queryParams['myIssues'] = myIssues.toString();
    if (assignedToMe != null) queryParams['assignedToMe'] = assignedToMe.toString();

    String endpoint = '/issues';
    if (queryParams.isNotEmpty) {
      final query = queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
      endpoint += '?$query';
    }

    final response = await _apiClient.get(endpoint);
    if (response is List) {
      return response.map((e) => IssueModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<IssueModel> getIssueById(String id) async {
    final response = await _apiClient.get('/issues/$id');
    return IssueModel.fromJson(response as Map<String, dynamic>);
  }

  Future<IssueModel> updateStatus(String id, String status, {String? comment}) async {
    final response = await _apiClient.patch('/issues/$id/status', {
      'status': status,
      if (comment != null) 'comment': comment,
    });
    return IssueModel.fromJson(response as Map<String, dynamic>);
  }

  Future<IssueModel> assignIssue(String id, {String? assignedTeamId, String? assignedUserId, String? comment}) async {
    final response = await _apiClient.post('/issues/$id/assign', {
      if (assignedTeamId != null) 'assignedTeamId': assignedTeamId,
      if (assignedUserId != null) 'assignedUserId': assignedUserId,
      if (comment != null) 'comment': comment,
    });
    return IssueModel.fromJson(response as Map<String, dynamic>);
  }

  Future<List<TimelineEventModel>> getTimeline(String id) async {
    final response = await _apiClient.get('/issues/$id/timeline');
    if (response is List) {
      return response.map((e) => TimelineEventModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
