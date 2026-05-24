import '../domain/auth_session.dart';
import 'auth_repository.dart';
import 'token_storage.dart';

class LoginUseCase {
  const LoginUseCase(this._repository, this._tokenStorage);

  final AuthRepository _repository;
  final TokenStorage _tokenStorage;

  Future<AuthSession> call({
    required String email,
    required String password,
  }) async {
    final session = await _repository.login(email: email, password: password);
    await _tokenStorage.saveSession(session);
    return session;
  }
}
