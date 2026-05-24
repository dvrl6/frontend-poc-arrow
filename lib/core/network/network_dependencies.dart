import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../../features/auth/infrastructure/auth_dependencies.dart';
import 'api_client.dart';
import 'http_api_client.dart';

class NetworkDependencies {
  const NetworkDependencies._();

  static Future<ApiClient> createApiClient({http.Client? httpClient}) async {
    final tokenStorage = await AuthDependencies.createTokenStorage();
    return HttpApiClient(
      httpClient: httpClient ?? http.Client(),
      baseUrl: AppConfig.apiBaseUrl,
      tokenProvider: tokenStorage.getAccessToken,
    );
  }
}
