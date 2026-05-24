import '../../../core/network/api_client.dart';
import '../application/remote_level_repository.dart';

class ApiRemoteLevelRepository implements RemoteLevelRepository {
  const ApiRemoteLevelRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Map<int, String>> getLevelIdsByNumber() async {
    final response = await _apiClient.get('/levels');
    if (response is! List) {
      throw const FormatException('Invalid levels response.');
    }

    final mapping = <int, String>{};
    for (final item in response) {
      if (item is! Map<String, Object?>) {
        continue;
      }
      final number = (item['number'] as num?)?.toInt();
      final id = item['id']?.toString();
      if (number != null && id != null && id.isNotEmpty) {
        mapping[number] = id;
      }
    }
    return mapping;
  }
}
