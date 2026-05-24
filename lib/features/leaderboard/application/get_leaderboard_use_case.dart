import '../domain/leaderboard_entry.dart';
import 'leaderboard_repository.dart';

class GetLeaderboardUseCase {
  const GetLeaderboardUseCase(this._repository);

  final LeaderboardRepository _repository;

  Future<List<LeaderboardEntry>> call(String levelId) {
    return _repository.getForLevel(levelId);
  }
}
