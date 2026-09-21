import 'package:flutter/material.dart';
import '../data/models/audit_models.dart';
import '../data/repositories/audit_repository.dart';

class AuditProvider extends ChangeNotifier {
  final AuditRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;

  List<AuditEventModel> _issueAuditTrail = [];
  List<AuditEventModel> _systemAuditLogs = [];
  List<SecurityEventModel> _securityLogs = [];
  SystemStatusModel? _systemStatus;

  AuditProvider({AuditRepository? repository})
      : _repository = repository ?? AuditRepository();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<AuditEventModel> get issueAuditTrail => _issueAuditTrail;
  List<AuditEventModel> get systemAuditLogs => _systemAuditLogs;
  List<SecurityEventModel> get securityLogs => _securityLogs;
  SystemStatusModel? get systemStatus => _systemStatus;

  Future<void> loadIssueAuditTrail(String issueId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _issueAuditTrail = await _repository.getIssueAuditTrail(issueId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSystemAuditLogs({String? entityType, String? eventType}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _systemAuditLogs = await _repository.getSystemAuditLogs(
        entityType: entityType,
        eventType: eventType,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSystemStatus() async {
    try {
      _systemStatus = await _repository.getSystemStatus();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
