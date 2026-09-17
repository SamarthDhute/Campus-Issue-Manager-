import 'package:flutter/material.dart';
import '../data/models/operation_models.dart';
import '../data/repositories/operations_repository.dart';

class OperationsProvider with ChangeNotifier {
  final OperationsRepository _repository;

  OperationsProvider({OperationsRepository? repository})
      : _repository = repository ?? OperationsRepository();

  // State holders
  AssignmentRecommendationModel? _recommendation;
  List<AssignmentModel> _assignmentHistory = [];
  List<IssueMessageModel> _messages = [];
  List<InternalNoteModel> _internalNotes = [];
  List<InvestigationModel> _investigations = [];
  List<IssueTaskModel> _tasks = [];

  bool _isLoading = false;
  bool _isRecommending = false;
  bool _isAssigning = false;
  bool _isSendingMessage = false;
  bool _isAddingNote = false;
  bool _isSubmittingInvestigation = false;
  bool _isUpdatingTask = false;
  String? _errorMessage;

  // Getters
  AssignmentRecommendationModel? get recommendation => _recommendation;
  List<AssignmentModel> get assignmentHistory => _assignmentHistory;
  List<IssueMessageModel> get messages => _messages;
  List<InternalNoteModel> get internalNotes => _internalNotes;
  List<InvestigationModel> get investigations => _investigations;
  List<IssueTaskModel> get tasks => _tasks;

  bool get isLoading => _isLoading;
  bool get isRecommending => _isRecommending;
  bool get isAssigning => _isAssigning;
  bool get isSendingMessage => _isSendingMessage;
  bool get isAddingNote => _isAddingNote;
  bool get isSubmittingInvestigation => _isSubmittingInvestigation;
  bool get isUpdatingTask => _isUpdatingTask;
  String? get errorMessage => _errorMessage;

  int get completedTasksCount => _tasks.where((t) => t.isCompleted).length;
  double get taskProgress => _tasks.isEmpty ? 0.0 : completedTasksCount / _tasks.length;

  void clear() {
    _recommendation = null;
    _assignmentHistory = [];
    _messages = [];
    _internalNotes = [];
    _investigations = [];
    _tasks = [];
    _errorMessage = null;
    notifyListeners();
  }

  // Load all operations data for an issue
  Future<void> loadOperationsData(String issueId, {bool isStaff = true}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getTasks(issueId),
        _repository.getMessages(issueId),
        _repository.getAssignmentHistory(issueId),
        if (isStaff) _repository.getInternalNotes(issueId) else Future.value(<InternalNoteModel>[]),
        if (isStaff) _repository.getInvestigations(issueId) else Future.value(<InvestigationModel>[]),
      ]);

      _tasks = results[0] as List<IssueTaskModel>;
      _messages = results[1] as List<IssueMessageModel>;
      _assignmentHistory = results[2] as List<AssignmentModel>;
      if (isStaff) {
        _internalNotes = results[3] as List<InternalNoteModel>;
        _investigations = results[4] as List<InvestigationModel>;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch Smart Assignment Recommendation
  Future<void> fetchRecommendation(String issueId) async {
    _isRecommending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _recommendation = await _repository.getAssignmentRecommendation(issueId);
      _isRecommending = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isRecommending = false;
      notifyListeners();
    }
  }

  // Assign Issue
  Future<bool> assignIssue(
    String issueId, {
    required String userId,
    String? teamId,
    String? assignmentType,
    String? recommendationSource,
    String? reason,
  }) async {
    _isAssigning = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newAssignment = await _repository.assignIssue(
        issueId,
        userId: userId,
        teamId: teamId,
        assignmentType: assignmentType,
        recommendationSource: recommendationSource,
        reason: reason,
      );

      _assignmentHistory.insert(0, newAssignment);
      _isAssigning = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isAssigning = false;
      notifyListeners();
      return false;
    }
  }

  // Send Public Message
  Future<bool> sendMessage(String issueId, String body, {String? messageType}) async {
    if (body.trim().isEmpty) return false;
    _isSendingMessage = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final msg = await _repository.sendMessage(issueId, body.trim(), messageType: messageType);
      _messages.add(msg);
      _isSendingMessage = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isSendingMessage = false;
      notifyListeners();
      return false;
    }
  }

  // Add Internal Note
  Future<bool> addInternalNote(String issueId, String body) async {
    if (body.trim().isEmpty) return false;
    _isAddingNote = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final note = await _repository.addInternalNote(issueId, body.trim());
      _internalNotes.insert(0, note);
      _isAddingNote = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isAddingNote = false;
      notifyListeners();
      return false;
    }
  }

  // Submit Investigation
  Future<bool> submitInvestigation(
    String issueId, {
    required String observations,
    String? actionsTaken,
    String? findings,
    String? followUp,
  }) async {
    _isSubmittingInvestigation = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final inv = await _repository.submitInvestigation(
        issueId,
        observations: observations,
        actionsTaken: actionsTaken,
        findings: findings,
        followUp: followUp,
      );
      _investigations.insert(0, inv);
      _isSubmittingInvestigation = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isSubmittingInvestigation = false;
      notifyListeners();
      return false;
    }
  }

  // Create Sub-task
  Future<bool> createTask(String issueId, {required String title, String? description, String? ownerId, DateTime? dueAt}) async {
    if (title.trim().isEmpty) return false;
    _isUpdatingTask = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final task = await _repository.createTask(
        issueId,
        title: title.trim(),
        description: description,
        ownerId: ownerId,
        dueAt: dueAt,
      );
      _tasks.add(task);
      _isUpdatingTask = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isUpdatingTask = false;
      notifyListeners();
      return false;
    }
  }

  // Toggle/Update Sub-task
  Future<void> toggleTaskStatus(IssueTaskModel task) async {
    final newStatus = task.isCompleted ? 'PENDING' : 'COMPLETED';
    _isUpdatingTask = true;
    notifyListeners();

    try {
      final updated = await _repository.updateTask(task.id, status: newStatus);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = updated;
      }
      _isUpdatingTask = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isUpdatingTask = false;
      notifyListeners();
    }
  }
}
