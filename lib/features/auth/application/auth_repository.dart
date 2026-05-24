import '../domain/auth_session.dart';

abstract interface class AuthRepository {
  Future<AuthSession> login({required String email, required String password});

  Future<AuthSession> register({
    required String displayName,
    required String email,
    required String password,
  });
}
