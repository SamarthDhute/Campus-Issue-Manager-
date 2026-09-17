class AppConstants {
  static const String appName = 'Smart Campus Issue Manager';
  static const String apiBaseUrl = 'http://localhost:8081/api/v1';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String userProfileEndpoint = '/users/me';
  static const String healthEndpoint = '/health';
  static const String notificationsEndpoint = '/notifications';

  // Roles
  static const String roleStudent = 'STUDENT';
  static const String roleOperator = 'OPERATOR';
  static const String roleTeamLead = 'TEAM_LEAD';
  static const String roleManager = 'MANAGER';
  static const String roleAdmin = 'ADMIN';
}
