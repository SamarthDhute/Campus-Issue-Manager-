import 'package:flutter/material.dart';
import '../../data/models/sla_models.dart';
import '../../data/repositories/sla_repository.dart';

class SlaProvider extends ChangeNotifier {
  final SlaRepository _repository;

  IssueSlaModel? _sla;
  List<RiskEventModel> _risks = [];
  List<EscalationModel> _escalations = [];
  bool _isLoading = false;
  String? _errorMessage;

  int _currentResponseSeconds = 0;
  int _currentResolutionSeconds = 0;

  SlaProvider({SlaRepository? repository})
      : _repository = repository ?? SlaRepository();

  IssueSlaModel? get sla => _sla;
  List<RiskEventModel> get risks => _risks;
  List<EscalationModel> get escalations => _escalations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get currentResponseSeconds => _currentResponseSeconds;
  int get currentResolutionSeconds => _currentResolutionSeconds;

  Future<void> loadSlaData(String issueId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getIssueSla(issueId),
        _repository.getIssueRisks(issueId),
        _repository.getIssueEscalations(issueId),
      ]);

      _sla = results[0] as IssueSlaModel;
      _risks = results[1] as List<RiskEventModel>;
      _escalations = results[2] as List<EscalationModel>;

      _currentResponseSeconds = _sla?.responseSecondsRemaining ?? 0;
      _currentResolutionSeconds = _sla?.resolutionSecondsRemaining ?? 0;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> escalateIssue(String issueId, {required int level, required String reason}) async {
    try {
      final escalation = await _repository.createManualEscalation(
        issueId,
        level: level,
        reason: reason,
      );
      _escalations.insert(0, escalation);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
