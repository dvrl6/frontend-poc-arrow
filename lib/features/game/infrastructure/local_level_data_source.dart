import 'asset_text_loader.dart';
import 'manual_level_dto.dart';

class LocalLevelDataSource {
  const LocalLevelDataSource({
    required AssetTextLoader assetTextLoader,
    this.assetPath = manualLevelsAssetPath,
  }) : _assetTextLoader = assetTextLoader;

  static const manualLevelsAssetPath = 'assets/levels/manual_levels.json';

  final AssetTextLoader _assetTextLoader;
  final String assetPath;

  Future<List<ManualLevelDto>> loadManualLevels() async {
    final source = await _assetTextLoader.loadString(assetPath);
    return ManualLevelCollectionDto.fromJsonString(source).levels;
  }
}
