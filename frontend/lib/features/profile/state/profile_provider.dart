import 'package:flutter/material.dart';
import 'package:smart_campus_issue_manager/core/errors/app_exception.dart';
import 'package:smart_campus_issue_manager/features/auth/data/models/auth_user_model.dart';
import '../data/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _profileRepository;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  AuthUserModel? _user;

  ProfileProvider({ProfileRepository? profileRepository})
      : _profileRepository = profileRepository ?? ProfileRepository();

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  AuthUserModel? get user => _user;

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _profileRepository.fetchProfile();
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(String displayName) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _profileRepository.updateProfile(displayName);
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update profile: $e';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
