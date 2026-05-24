import '../domain/leaderboard_entry.dart';

abstract interface class LeaderboardRepository {
  Future<List<LeaderboardEntry>> getForLevel(String levelId);

  Future<void> submitScore({
    required String levelId,
    required int score,
    required int moves,
    required int timeSeconds,
  });
}
