import 'package:flutter/services.dart';

abstract interface class AssetTextLoader {
  Future<String> loadString(String assetPath);
}

class RootBundleAssetTextLoader implements AssetTextLoader {
  const RootBundleAssetTextLoader();

  @override
  Future<String> loadString(String assetPath) {
    return rootBundle.loadString(assetPath);
  }
}
