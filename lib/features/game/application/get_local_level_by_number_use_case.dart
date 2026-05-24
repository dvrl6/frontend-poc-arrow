import '../domain/level.dart';
import 'level_repository.dart';

class GetLocalLevelByNumberUseCase {
  const GetLocalLevelByNumberUseCase(this._levelRepository);

  final LevelRepository _levelRepository;

  Future<Level?> call(int number) {
    return _levelRepository.getManualLevelByNumber(number);
  }
}
