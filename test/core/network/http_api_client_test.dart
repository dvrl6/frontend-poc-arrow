import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_poc_arrow/core/network/http_api_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('should_attach_bearer_token_when_authenticated', () async {
    late final http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response('{"ok":true}', 200);
    });
    final apiClient = HttpApiClient(
      httpClient: client,
      baseUrl: 'http://example.test',
      tokenProvider: () async => 'token-123',
    );

    await apiClient.get('/progress/me', authenticated: true);

    expect(capturedRequest.headers['Authorization'], 'Bearer token-123');
  });
}
