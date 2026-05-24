import 'authenticated_user.dart';

class AuthSession {
  const AuthSession({required this.accessToken, required this.user});

  final String accessToken;
  final AuthenticatedUser user;

  Map<String, Object?> toJson() {
    return {'accessToken': accessToken, 'user': user.toJson()};
  }

  factory AuthSession.fromJson(Map<String, Object?> json) {
    final userJson = json['user'];
    return AuthSession(
      accessToken: json['accessToken']?.toString() ?? '',
      user: AuthenticatedUser.fromJson(
        userJson is Map<String, Object?> ? userJson : const <String, Object?>{},
      ),
    );
  }
}
