import 'local_progress_repository.dart';

class IsLevelUnlockedUseCase {
  const IsLevelUnlockedUseCase(this._repository);

  final LocalProgressRepository _repository;

  Future<bool> call(int levelNumber) async {
    final progress = await _repository.getProgress();
    return progress.isUnlocked(levelNumber);
  }
}
