import '../application/level_repository.dart';
import '../domain/level.dart';
import '../domain/level_definition_validator.dart';
import 'level_definition_mapper.dart';
import 'local_level_data_source.dart';

class AssetLevelRepository implements LevelRepository {
  const AssetLevelRepository({
    required LocalLevelDataSource localLevelDataSource,
    LevelDefinitionMapper levelDefinitionMapper = const LevelDefinitionMapper(),
    LevelDefinitionValidator levelDefinitionValidator =
        const LevelDefinitionValidator(),
  }) : _localLevelDataSource = localLevelDataSource,
       _levelDefinitionMapper = levelDefinitionMapper,
       _levelDefinitionValidator = levelDefinitionValidator;

  final LocalLevelDataSource _localLevelDataSource;
  final LevelDefinitionMapper _levelDefinitionMapper;
  final LevelDefinitionValidator _levelDefinitionValidator;

  @override
  Future<List<Level>> getManualLevels() async {
    final dtos = await _localLevelDataSource.loadManualLevels();
    return dtos
        .map(_levelDefinitionMapper.toDomain)
        .map(_levelDefinitionValidator.validate)
        .toList(growable: false);
  }

  @override
  Future<Level?> getManualLevelByNumber(int number) async {
    final levels = await getManualLevels();
    for (final level in levels) {
      if (level.number == number) {
        return level;
      }
    }
    return null;
  }
}
