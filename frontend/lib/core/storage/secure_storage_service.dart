import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../features/auth/data/models/auth_user_model.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  static const String _keyToken = 'access_token';
  static const String _keyUser = 'cached_user_profile';

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  Future<void> saveUser(AuthUserModel user) async {
    await _storage.write(key: _keyUser, value: jsonEncode(user.toJson()));
  }

  Future<AuthUserModel?> getUser() async {
    final userJson = await _storage.read(key: _keyUser);
    if (userJson == null || userJson.isEmpty) return null;
    try {
      return AuthUserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAll() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyUser);
  }
}
