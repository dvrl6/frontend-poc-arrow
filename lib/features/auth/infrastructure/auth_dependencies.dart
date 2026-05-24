import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/http_api_client.dart';
import '../application/get_auth_session_use_case.dart';
import '../application/login_use_case.dart';
import '../application/logout_use_case.dart';
import '../application/register_use_case.dart';
import '../application/token_storage.dart';
import 'api_auth_repository.dart';
import 'shared_preferences_token_storage.dart';

class AuthDependencies {
  const AuthDependencies._();

  static Future<TokenStorage> createTokenStorage() async {
    return SharedPreferencesTokenStorage(await SharedPreferences.getInstance());
  }

  static Future<ApiClient> createApiClient({http.Client? httpClient}) async {
    final tokenStorage = await createTokenStorage();
    return HttpApiClient(
      httpClient: httpClient ?? http.Client(),
      baseUrl: AppConfig.apiBaseUrl,
      tokenProvider: tokenStorage.getAccessToken,
    );
  }

  static Future<LoginUseCase> createLoginUseCase() async {
    final tokenStorage = await createTokenStorage();
    return LoginUseCase(
      ApiAuthRepository(await createApiClient()),
      tokenStorage,
    );
  }

  static Future<RegisterUseCase> createRegisterUseCase() async {
    final tokenStorage = await createTokenStorage();
    return RegisterUseCase(
      ApiAuthRepository(await createApiClient()),
      tokenStorage,
    );
  }

  static Future<LogoutUseCase> createLogoutUseCase() async {
    return LogoutUseCase(await createTokenStorage());
  }

  static Future<GetAuthSessionUseCase> createGetAuthSessionUseCase() async {
    return GetAuthSessionUseCase(await createTokenStorage());
  }
}
