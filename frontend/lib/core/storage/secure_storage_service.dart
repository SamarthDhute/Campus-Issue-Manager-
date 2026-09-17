import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_campus_issue_manager/features/auth/data/models/auth_user_model.dart';

class SecureStorageService {
  FlutterSecureStorage? _storage;
  static String? _memoryToken;
  static AuthUserModel? _memoryUser;

  static const String _keyToken = 'access_token';
  static const String _keyUser = 'cached_user_profile';

  SecureStorageService() {
    if (!kIsWeb) {
      try {
        _storage = const FlutterSecureStorage();
      } catch (_) {
        _storage = null;
      }
    }
  }

  Future<void> saveToken(String token) async {
    _memoryToken = token;
    if (!kIsWeb && _storage != null) {
      try {
        await _storage!.write(key: _keyToken, value: token);
      } catch (e) {
        debugPrint('SecureStorage write error: $e');
      }
    }
  }

  Future<String?> getToken() async {
    if (_memoryToken != null) return _memoryToken;
    if (!kIsWeb && _storage != null) {
      try {
        final val = await _storage!.read(key: _keyToken);
        if (val != null) _memoryToken = val;
        return val;
      } catch (e) {
        debugPrint('SecureStorage read error: $e');
      }
    }
    return _memoryToken;
  }

  Future<void> saveUser(AuthUserModel user) async {
    _memoryUser = user;
    if (!kIsWeb && _storage != null) {
      try {
        await _storage!.write(key: _keyUser, value: jsonEncode(user.toJson()));
      } catch (e) {
        debugPrint('SecureStorage write user error: $e');
      }
    }
  }

  Future<AuthUserModel?> getUser() async {
    if (_memoryUser != null) return _memoryUser;
    if (!kIsWeb && _storage != null) {
      try {
        final userJson = await _storage!.read(key: _keyUser);
        if (userJson != null && userJson.isNotEmpty) {
          final parsed = AuthUserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
          _memoryUser = parsed;
          return parsed;
        }
      } catch (e) {
        debugPrint('SecureStorage read user error: $e');
      }
    }
    return _memoryUser;
  }

  Future<void> clearAll() async {
    _memoryToken = null;
    _memoryUser = null;
    if (!kIsWeb && _storage != null) {
      try {
        await _storage!.delete(key: _keyToken);
        await _storage!.delete(key: _keyUser);
      } catch (e) {
        debugPrint('SecureStorage clear error: $e');
      }
    }
  }
}
