import '../../auth/application/token_storage.dart';
import '../../leaderboard/application/submit_leaderboard_score_use_case.dart';
import 'sync_progress_use_case.dart';

class NotifyRemoteLevelCompletionUseCase {
  const NotifyRemoteLevelCompletionUseCase({
    required TokenStorage tokenStorage,
    required SyncProgressUseCase syncProgress,
    required SubmitLeaderboardScoreUseCase submitLeaderboardScore,
  }) : _tokenStorage = tokenStorage,
       _syncProgress = syncProgress,
       _submitLeaderboardScore = submitLeaderboardScore;

  final TokenStorage _tokenStorage;
  final SyncProgressUseCase _syncProgress;
  final SubmitLeaderboardScoreUseCase _submitLeaderboardScore;

  Future<bool> call({
    required int levelNumber,
    required int score,
    required int moves,
    required int timeSeconds,
  }) async {
    final token = await _tokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    try {
      await _syncProgress();
      await _submitLeaderboardScore(
        levelNumber: levelNumber,
        score: score,
        moves: moves,
        timeSeconds: timeSeconds,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
