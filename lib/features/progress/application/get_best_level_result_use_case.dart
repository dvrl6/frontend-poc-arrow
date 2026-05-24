import '../domain/level_best_result.dart';
import 'local_progress_repository.dart';

class GetBestLevelResultUseCase {
  const GetBestLevelResultUseCase(this._repository);

  final LocalProgressRepository _repository;

  Future<LevelBestResult?> call(int levelNumber) async {
    final progress = await _repository.getProgress();
    return progress.bestResultFor(levelNumber);
  }
}
