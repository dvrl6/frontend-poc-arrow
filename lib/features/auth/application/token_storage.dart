import '../domain/auth_session.dart';

abstract interface class TokenStorage {
  Future<AuthSession?> getSession();

  Future<String?> getAccessToken();

  Future<void> saveSession(AuthSession session);

  Future<void> clearSession();
}
