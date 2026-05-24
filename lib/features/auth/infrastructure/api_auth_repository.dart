import '../../../core/network/api_client.dart';
import '../application/auth_repository.dart';
import '../domain/auth_session.dart';

class ApiAuthRepository implements AuthRepository {
  const ApiAuthRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );
    return _parseSession(response);
  }

  @override
  Future<AuthSession> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/register',
      body: {'displayName': displayName, 'email': email, 'password': password},
    );
    return _parseSession(response);
  }

  AuthSession _parseSession(Object? response) {
    if (response is! Map<String, Object?>) {
      throw const FormatException('Invalid auth response.');
    }
    return AuthSession.fromJson(response);
  }
}
