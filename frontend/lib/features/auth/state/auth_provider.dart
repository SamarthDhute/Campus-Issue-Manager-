import 'package:flutter/material.dart';
import 'package:smart_campus_issue_manager/core/errors/app_exception.dart';
import '../data/models/auth_user_model.dart';
import '../data/repositories/auth_repository.dart';

enum AuthStatus {
  uninitialized,
  authenticating,
  authenticated,
  unauthenticated,
}

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthStatus _status = AuthStatus.unauthenticated;
  AuthUserModel? _user;
  String? _errorMessage;

  AuthProvider({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  AuthStatus get status => _status;
  AuthUserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _user != null;

  bool get isStudent => _user?.role.toUpperCase() == 'STUDENT' || _user?.role.toUpperCase() == 'REQUESTER';
  bool get isOperator => _user?.role.toUpperCase() == 'OPERATOR' || _user?.role.toUpperCase() == 'FACULTY_STAFF' || _user?.role.toUpperCase() == 'STAFF';
  bool get isTeamLead => _user?.role.toUpperCase() == 'TEAM_LEAD';
  bool get isCampusManager => _user?.role.toUpperCase() == 'CAMPUS_MANAGER' || _user?.role.toUpperCase() == 'MANAGER';
  bool get isAdmin => _user?.role.toUpperCase() == 'ADMIN';

  Future<void> checkAuthStatus() async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      final token = await _authRepository.getToken();
      final user = await _authRepository.getCurrentUser();

      if (token != null && token.isNotEmpty && user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
      } else {
        _user = null;
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _user = null;
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepository.login(email.trim(), password);
      _user = response.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  void loginAsDemoRole(String role) {
    String name;
    String email;
    List<String> teams = [];

    switch (role.toUpperCase()) {
      case 'OPERATOR':
        name = 'Vikram Singh';
        email = 'operator@smartcampus.edu';
        teams = ['Electrical Maintenance', 'Hostel Facilities'];
        break;
      case 'TEAM_LEAD':
        name = 'Dr. Priya Sharma';
        email = 'teamlead@smartcampus.edu';
        teams = ['Campus Operations Lead'];
        break;
      case 'MANAGER':
        name = 'Rajesh Verma';
        email = 'manager@smartcampus.edu';
        teams = ['Campus Executive Council'];
        break;
      case 'ADMIN':
        name = 'System Administrator';
        email = 'admin@smartcampus.edu';
        teams = ['IT Infrastructure'];
        break;
      case 'STUDENT':
      default:
        name = 'Aarav Sharma';
        email = 'student@smartcampus.edu';
        teams = ['Hostel Block B'];
        break;
    }

    _user = AuthUserModel(
      id: 'demo-user-id',
      email: email,
      displayName: name,
      role: role.toUpperCase(),
      organizationName: 'Smart Campus University',
      teams: teams,
    );
    _status = AuthStatus.authenticated;
    _errorMessage = null;
    notifyListeners();
  }

  void updateUser(AuthUserModel updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _user = null;
    _errorMessage = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
