import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus_issue_manager/features/auth/data/models/auth_user_model.dart';
import 'package:smart_campus_issue_manager/features/auth/state/auth_provider.dart';

void main() {
  group('AuthProvider State Tests', () {
    test('Initial status should be uninitialized', () {
      final provider = AuthProvider();
      expect(provider.status, AuthStatus.uninitialized);
      expect(provider.user, isNull);
      expect(provider.isAuthenticated, isFalse);
    });

    test('updateUser should update current user profile and notify listeners', () {
      final provider = AuthProvider();
      final user = AuthUserModel(
        id: '123',
        email: 'test@smartcampus.edu',
        displayName: 'Test User',
        role: 'STUDENT',
        teams: [],
      );

      provider.updateUser(user);

      expect(provider.user?.displayName, 'Test User');
      expect(provider.user?.email, 'test@smartcampus.edu');
    });
  });
}
