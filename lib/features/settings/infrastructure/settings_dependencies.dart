import 'package:shared_preferences/shared_preferences.dart';

import '../application/get_player_settings_use_case.dart';
import '../application/save_player_settings_use_case.dart';
import '../application/settings_repository.dart';
import 'shared_preferences_settings_repository.dart';

class SettingsDependencies {
  const SettingsDependencies._();

  static Future<SettingsRepository> createRepository() async {
    return SharedPreferencesSettingsRepository(
      await SharedPreferences.getInstance(),
    );
  }

  static Future<GetPlayerSettingsUseCase>
  createGetPlayerSettingsUseCase() async {
    return GetPlayerSettingsUseCase(await createRepository());
  }

  static Future<SavePlayerSettingsUseCase>
  createSavePlayerSettingsUseCase() async {
    return SavePlayerSettingsUseCase(await createRepository());
  }
}
