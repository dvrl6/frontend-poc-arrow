import '../domain/level.dart';

abstract interface class LevelRepository {
  Future<List<Level>> getManualLevels();

  Future<Level?> getManualLevelByNumber(int number);
}
