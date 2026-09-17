import 'auth_user_model.dart';

class AuthResponse {
  final String accessToken;
  final String tokenType;
  final int expiresInMs;
  final AuthUserModel user;

  AuthResponse({
    required this.accessToken,
    this.tokenType = 'Bearer',
    required this.expiresInMs,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      expiresInMs: (json['expiresInMs'] as num?)?.toInt() ?? 86400000,
      user: AuthUserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'tokenType': tokenType,
      'expiresInMs': expiresInMs,
      'user': user.toJson(),
    };
  }
}
