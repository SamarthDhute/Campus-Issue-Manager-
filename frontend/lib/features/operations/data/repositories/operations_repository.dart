import 'package:smart_campus_issue_manager/core/network/api_client.dart';
import '../models/operation_models.dart';

class OperationsRepository {
  final ApiClient _apiClient;

  OperationsRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // Smart Assignment Recommendation
  Future<AssignmentRecommendationModel> getAssignmentRecommendation(String issueId) async {
    final response = await _apiClient.post('/issues/$issueId/assignment-recommendation', {});
    return AssignmentRecommendationModel.fromJson(response as Map<String, dynamic>);
  }

  // Assign Issue
  Future<AssignmentModel> assignIssue(
    String issueId, {
    required String userId,
    String? teamId,
    String? assignmentType,
    String? recommendationSource,
    String? reason,
  }) async {
    final response = await _apiClient.post('/issues/$issueId/dispatch', {
      'userId': userId,
      if (teamId != null) 'teamId': teamId,
      'assignmentType': assignmentType ?? 'PRIMARY',
      'recommendationSource': recommendationSource ?? 'MANUAL',
      if (reason != null) 'reason': reason,
    });
    return AssignmentModel.fromJson(response as Map<String, dynamic>);
  }

  // Get Assignment History
  Future<List<AssignmentModel>> getAssignmentHistory(String issueId) async {
    final response = await _apiClient.get('/issues/$issueId/assignments');
    if (response is List) {
      return response.map((e) => AssignmentModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // Messages / Requester Communication
  Future<IssueMessageModel> sendMessage(String issueId, String body, {String? messageType}) async {
    final response = await _apiClient.post('/issues/$issueId/messages', {
      'body': body,
      if (messageType != null) 'messageType': messageType,
    });
    return IssueMessageModel.fromJson(response as Map<String, dynamic>);
  }

  Future<List<IssueMessageModel>> getMessages(String issueId) async {
    final response = await _apiClient.get('/issues/$issueId/messages');
    if (response is List) {
      return response.map((e) => IssueMessageModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // Internal Notes
  Future<InternalNoteModel> addInternalNote(String issueId, String body) async {
    final response = await _apiClient.post('/issues/$issueId/internal-notes', {
      'body': body,
    });
    return InternalNoteModel.fromJson(response as Map<String, dynamic>);
  }

  Future<List<InternalNoteModel>> getInternalNotes(String issueId) async {
    final response = await _apiClient.get('/issues/$issueId/internal-notes');
    if (response is List) {
      return response.map((e) => InternalNoteModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // Field Investigation
  Future<InvestigationModel> submitInvestigation(
    String issueId, {
    required String observations,
    String? actionsTaken,
    String? findings,
    String? followUp,
  }) async {
    final response = await _apiClient.post('/issues/$issueId/investigations', {
      'observations': observations,
      if (actionsTaken != null) 'actionsTaken': actionsTaken,
      if (findings != null) 'findings': findings,
      if (followUp != null) 'followUp': followUp,
    });
    return InvestigationModel.fromJson(response as Map<String, dynamic>);
  }

  Future<List<InvestigationModel>> getInvestigations(String issueId) async {
    final response = await _apiClient.get('/issues/$issueId/investigations');
    if (response is List) {
      return response.map((e) => InvestigationModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // Sub-tasks
  Future<IssueTaskModel> createTask(
    String issueId, {
    required String title,
    String? description,
    String? ownerId,
    DateTime? dueAt,
  }) async {
    final response = await _apiClient.post('/issues/$issueId/tasks', {
      'title': title,
      if (description != null) 'description': description,
      if (ownerId != null) 'ownerId': ownerId,
      if (dueAt != null) 'dueAt': dueAt.toIso8601String(),
    });
    return IssueTaskModel.fromJson(response as Map<String, dynamic>);
  }

  Future<IssueTaskModel> updateTask(
    String taskId, {
    String? title,
    String? description,
    String? status,
    String? ownerId,
    DateTime? dueAt,
  }) async {
    final response = await _apiClient.patch('/tasks/$taskId', {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (ownerId != null) 'ownerId': ownerId,
      if (dueAt != null) 'dueAt': dueAt.toIso8601String(),
    });
    return IssueTaskModel.fromJson(response as Map<String, dynamic>);
  }

  Future<List<IssueTaskModel>> getTasks(String issueId) async {
    final response = await _apiClient.get('/issues/$issueId/tasks');
    if (response is List) {
      return response.map((e) => IssueTaskModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
