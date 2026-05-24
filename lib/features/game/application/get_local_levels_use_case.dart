import '../domain/level.dart';
import 'level_repository.dart';

class GetLocalLevelsUseCase {
  const GetLocalLevelsUseCase(this._levelRepository);

  final LevelRepository _levelRepository;

  Future<List<Level>> call() {
    return _levelRepository.getManualLevels();
  }
}
