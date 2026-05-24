import '../../../core/network/api_client.dart';
import '../application/leaderboard_repository.dart';
import '../domain/leaderboard_entry.dart';

class ApiLeaderboardRepository implements LeaderboardRepository {
  const ApiLeaderboardRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<LeaderboardEntry>> getForLevel(String levelId) async {
    final response = await _apiClient.get('/leaderboard/$levelId');
    if (response is! List) {
      throw const FormatException('Invalid leaderboard response.');
    }
    return response
        .whereType<Map<String, Object?>>()
        .map(_entryFromJson)
        .toList(growable: false);
  }

  @override
  Future<void> submitScore({
    required String levelId,
    required int score,
    required int moves,
    required int timeSeconds,
  }) async {
    await _apiClient.post(
      '/leaderboard',
      authenticated: true,
      body: {
        'levelId': levelId,
        'score': score,
        'moves': moves,
        'timeSeconds': timeSeconds,
      },
    );
  }

  LeaderboardEntry _entryFromJson(Map<String, Object?> json) {
    final user = json['user'];
    return LeaderboardEntry(
      id: json['id']?.toString() ?? '',
      levelId: json['levelId']?.toString() ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      moves: (json['moves'] as num?)?.toInt() ?? 0,
      timeSeconds: (json['timeSeconds'] as num?)?.toInt() ?? 0,
      displayName: user is Map<String, Object?>
          ? user['displayName']?.toString() ?? 'Player'
          : 'Player',
    );
  }
}
