class AuthUserModel {
  final String id;
  final String email;
  final String displayName;
  final String role;
  final String? organizationId;
  final String? organizationName;
  final List<String> teams;

  AuthUserModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.organizationId,
    this.organizationName,
    required this.teams,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      role: json['role'] as String,
      organizationId: json['organizationId'] as String?,
      organizationName: json['organizationName'] as String?,
      teams: (json['teams'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'role': role,
      'organizationId': organizationId,
      'organizationName': organizationName,
      'teams': teams,
    };
  }
}
