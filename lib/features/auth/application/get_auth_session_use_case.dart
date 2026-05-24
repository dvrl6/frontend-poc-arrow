import '../domain/auth_session.dart';
import 'token_storage.dart';

class GetAuthSessionUseCase {
  const GetAuthSessionUseCase(this._tokenStorage);

  final TokenStorage _tokenStorage;

  Future<AuthSession?> call() {
    return _tokenStorage.getSession();
  }
}
