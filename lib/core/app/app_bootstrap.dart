import 'package:flutter/widgets.dart';

import '../../features/settings/infrastructure/settings_dependencies.dart';
import 'app_settings_controller.dart';
import 'arrow_poc_app.dart';

/// Composition Root: assembles app-level startup state and returns the configured root widget. 
Future<Widget> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final getPlayerSettings =
      await SettingsDependencies.createGetPlayerSettingsUseCase();
  final settings = await getPlayerSettings();
  final initialLocale =
      settings.languageCode == null ? null : Locale(settings.languageCode!);

  return ArrowPocApp(
    appSettings: AppSettingsController(initialLocale: initialLocale),
  );
}