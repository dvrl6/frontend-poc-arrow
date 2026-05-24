class AuthenticatedUser {
  const AuthenticatedUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
  });

  final String id;
  final String email;
  final String displayName;
  final String role;

  Map<String, Object?> toJson() {
    return {'id': id, 'email': email, 'displayName': displayName, 'role': role};
  }

  factory AuthenticatedUser.fromJson(Map<String, Object?> json) {
    return AuthenticatedUser(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? '',
      role: json['role']?.toString() ?? 'PLAYER',
    );
  }
}
