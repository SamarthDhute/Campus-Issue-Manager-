import 'package:flutter/material.dart';
import '../data/models/ai_models.dart';
import '../data/repositories/ai_repository.dart';

class AiProvider with ChangeNotifier {
  final AiRepository _aiRepository;

  AiProvider({AiRepository? aiRepository})
      : _aiRepository = aiRepository ?? AiRepository();

  AiAnalysisModel? _currentAnalysis;
  List<RelatedIssueModel> _relatedIssues = [];
  bool _isLoading = false;
  bool _isAnalyzing = false;
  bool _isDeciding = false;
  String? _errorMessage;

  AiAnalysisModel? get currentAnalysis => _currentAnalysis;
  List<RelatedIssueModel> get relatedIssues => _relatedIssues;
  bool get isLoading => _isLoading;
  bool get isAnalyzing => _isAnalyzing;
  bool get isDeciding => _isDeciding;
  String? get errorMessage => _errorMessage;

  void clear() {
    _currentAnalysis = null;
    _relatedIssues = [];
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadAnalysis(String issueId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentAnalysis = await _aiRepository.getAnalysis(issueId);
      _relatedIssues = await _aiRepository.getRelatedIssues(issueId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> triggerAnalysis(String issueId) async {
    _isAnalyzing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentAnalysis = await _aiRepository.triggerAnalysis(issueId);
      _relatedIssues = await _aiRepository.getRelatedIssues(issueId);
      _isAnalyzing = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  Future<bool> recordDecision(String issueId, String recommendationId, String decision) async {
    _isDeciding = true;
    notifyListeners();

    try {
      await _aiRepository.recordDecision(issueId, recommendationId, decision);
      // Reload analysis to update recommendations list
      _currentAnalysis = await _aiRepository.getAnalysis(issueId);
      _isDeciding = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isDeciding = false;
      notifyListeners();
      return false;
    }
  }
}
