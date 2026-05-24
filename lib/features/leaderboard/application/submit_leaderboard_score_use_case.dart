import '../../auth/application/token_storage.dart';
import '../../progress/application/remote_level_repository.dart';
import 'leaderboard_repository.dart';

class SubmitLeaderboardScoreUseCase {
  const SubmitLeaderboardScoreUseCase({
    required LeaderboardRepository leaderboardRepository,
    required RemoteLevelRepository remoteLevelRepository,
    required TokenStorage tokenStorage,
  }) : _leaderboardRepository = leaderboardRepository,
       _remoteLevelRepository = remoteLevelRepository,
       _tokenStorage = tokenStorage;

  final LeaderboardRepository _leaderboardRepository;
  final RemoteLevelRepository _remoteLevelRepository;
  final TokenStorage _tokenStorage;

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
    final levelIdsByNumber = await _remoteLevelRepository.getLevelIdsByNumber();
    final levelId = levelIdsByNumber[levelNumber];
    if (levelId == null) {
      return false;
    }
    await _leaderboardRepository.submitScore(
      levelId: levelId,
      score: score,
      moves: moves,
      timeSeconds: timeSeconds,
    );
    return true;
  }
}
