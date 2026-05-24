import 'token_storage.dart';

class LogoutUseCase {
  const LogoutUseCase(this._tokenStorage);

  final TokenStorage _tokenStorage;

  Future<void> call() {
    return _tokenStorage.clearSession();
  }
}
