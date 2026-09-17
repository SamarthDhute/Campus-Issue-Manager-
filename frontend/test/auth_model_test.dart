import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus_issue_manager/features/auth/data/models/auth_response.dart';
import 'package:smart_campus_issue_manager/features/auth/data/models/auth_user_model.dart';

void main() {
  group('AuthUserModel & AuthResponse Tests', () {
    test('AuthUserModel should deserialize correctly from JSON', () {
      final json = {
        'id': 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
        'email': 'student@smartcampus.edu',
        'displayName': 'Aarav Sharma',
        'role': 'STUDENT',
        'organizationId': '11111111-2222-3333-4444-555555555555',
        'organizationName': 'Smart Campus University',
        'teams': ['Hostel Council'],
      };

      final user = AuthUserModel.fromJson(json);

      expect(user.id, 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d');
      expect(user.email, 'student@smartcampus.edu');
      expect(user.displayName, 'Aarav Sharma');
      expect(user.role, 'STUDENT');
      expect(user.organizationName, 'Smart Campus University');
      expect(user.teams, contains('Hostel Council'));
    });

    test('AuthResponse should parse access token and user payload', () {
      final json = {
        'accessToken': 'dummy-jwt-token-12345',
        'tokenType': 'Bearer',
        'expiresInMs': 86400000,
        'user': {
          'id': 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
          'email': 'operator@smartcampus.edu',
          'displayName': 'Vikram Singh',
          'role': 'OPERATOR',
          'teams': ['Electrical Maintenance'],
        },
      };

      final authResponse = AuthResponse.fromJson(json);

      expect(authResponse.accessToken, 'dummy-jwt-token-12345');
      expect(authResponse.tokenType, 'Bearer');
      expect(authResponse.user.role, 'OPERATOR');
      expect(authResponse.user.displayName, 'Vikram Singh');
    });
  });
}
