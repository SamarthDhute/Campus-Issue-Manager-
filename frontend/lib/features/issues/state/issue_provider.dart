import 'package:flutter/material.dart';
import 'package:smart_campus_issue_manager/core/errors/app_exception.dart';
import '../data/models/issue_model.dart';
import '../data/models/timeline_event_model.dart';
import '../data/repositories/issue_repository.dart';

class IssueProvider extends ChangeNotifier {
  final IssueRepository _repository;

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  List<IssueModel> _issues = [];
  IssueModel? _selectedIssue;

  IssueProvider({IssueRepository? repository})
      : _repository = repository ?? IssueRepository();

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  List<IssueModel> get issues => _issues;
  IssueModel? get selectedIssue => _selectedIssue;

  Future<void> loadIssues({
    String? status,
    String? categoryId,
    bool? myIssues,
    bool? assignedToMe,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _issues = await _repository.getIssues(
        status: status,
        categoryId: categoryId,
        myIssues: myIssues,
        assignedToMe: assignedToMe,
      );
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load issues: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<IssueModel?> createIssue({
    required String title,
    required String description,
    required String categoryId,
    required String location,
    required String priority,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newIssue = await _repository.createIssue(
        title: title,
        description: description,
        categoryId: categoryId,
        location: location,
        priority: priority,
      );
      _issues.insert(0, newIssue);
      return newIssue;
    } on AppException catch (e) {
      _errorMessage = e.message;
      return null;
    } catch (e) {
      _errorMessage = 'Failed to submit issue: $e';
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> loadIssueDetails(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedIssue = await _repository.getIssueById(id);
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load issue details: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateIssueStatus(String id, String newStatus, {String? comment}) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.updateStatus(id, newStatus, comment: comment);
      _selectedIssue = updated;
      
      final index = _issues.indexWhere((i) => i.id == id);
      if (index != -1) {
        _issues[index] = updated;
      }
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update status: $e';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> assignIssue(String id, {String? assignedTeamId, String? assignedUserId, String? comment}) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.assignIssue(
        id,
        assignedTeamId: assignedTeamId,
        assignedUserId: assignedUserId,
        comment: comment,
      );
      _selectedIssue = updated;

      final index = _issues.indexWhere((i) => i.id == id);
      if (index != -1) {
        _issues[index] = updated;
      }
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Failed to assign issue: $e';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
