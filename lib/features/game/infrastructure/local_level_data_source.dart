import 'asset_text_loader.dart';
import 'manual_level_dto.dart';

class LocalLevelDataSource {
  const LocalLevelDataSource({
    required AssetTextLoader assetTextLoader,
    this.assetPath2d = manualLevels2dAssetPath,
    this.assetPath3d = manualLevels3dAssetPath,
  }) : _assetTextLoader = assetTextLoader;

  static const manualLevels2dAssetPath = 'assets/levels/manual_levels_2d.json';
  static const manualLevels3dAssetPath = 'assets/levels/manual_levels_3d.json';

  final AssetTextLoader _assetTextLoader;
  final String assetPath2d;
  final String assetPath3d;

  /// Loads both level files and concatenates them, preserving order (2D
  /// levels 1-20 then 3D levels 21-25). Internal level numbers stay globally
  /// unique across both files; this is purely a file-split of where each
  /// level is authored/loaded from.
  Future<List<ManualLevelDto>> loadManualLevels() async {
    final source2d = await _assetTextLoader.loadString(assetPath2d);
    final source3d = await _assetTextLoader.loadString(assetPath3d);
    return [
      ...ManualLevelCollectionDto.fromJsonString(source2d).levels,
      ...ManualLevelCollectionDto.fromJsonString(source3d).levels,
    ];
  }
}
