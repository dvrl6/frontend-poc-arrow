import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_poc_arrow/core/localization/l10n/app_localizations.dart';
import 'package:frontend_poc_arrow/core/theme/app_theme.dart';
import 'package:frontend_poc_arrow/features/game/presentation/game_ui_keys.dart';
import 'package:frontend_poc_arrow/features/progress/application/local_progress_repository.dart';
import 'package:frontend_poc_arrow/features/progress/application/reset_local_progress_use_case.dart';
import 'package:frontend_poc_arrow/features/progress/application/save_level_completion_use_case.dart';
import 'package:frontend_poc_arrow/features/progress/domain/local_progress.dart';
import 'package:frontend_poc_arrow/features/progress/infrastructure/shared_preferences_local_progress_repository.dart';
import 'package:frontend_poc_arrow/features/settings/application/get_player_settings_use_case.dart';
import 'package:frontend_poc_arrow/features/settings/application/save_player_settings_use_case.dart';
import 'package:frontend_poc_arrow/features/settings/application/settings_repository.dart';
import 'package:frontend_poc_arrow/features/settings/domain/player_settings.dart';
import 'package:frontend_poc_arrow/features/settings/infrastructure/shared_preferences_settings_repository.dart';
import 'package:frontend_poc_arrow/features/settings/presentation/settings_screen.dart';
import 'package:frontend_poc_arrow/features/settings/presentation/settings_screen_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('should_persist_sound_setting_when_toggled', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesSettingsRepository(preferences);
    final saveSettings = SavePlayerSettingsUseCase(repository);
    final getSettings = GetPlayerSettingsUseCase(repository);

    await saveSettings(
      const PlayerSettings(soundEnabled: false, musicEnabled: false),
    );

    final settings = await getSettings();
    expect(settings.soundEnabled, isFalse);
    expect(settings.musicEnabled, isFalse);
  });

  test('should_reset_local_progress_when_confirmed', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final settingsRepository = SharedPreferencesSettingsRepository(preferences);
    final progressRepository = SharedPreferencesLocalProgressRepository(
      preferences,
    );
    await SavePlayerSettingsUseCase(settingsRepository)(
      const PlayerSettings(soundEnabled: false, musicEnabled: true),
    );
    await SaveLevelCompletionUseCase(progressRepository)(
      levelNumber: 1,
      score: 990,
      moves: 1,
      timeSeconds: 0,
    );

    await progressRepository.resetProgress();

    final settings = await settingsRepository.getSettings();
    final progress = await progressRepository.getProgress();
    expect(settings.soundEnabled, isFalse);
    expect(settings.musicEnabled, isTrue);
    expect(progress.completedLevelNumbers, isEmpty);
    expect(progress.bestResultsByLevel, isEmpty);
    expect(progress.lastUnlockedLevel, 1);
  });

  testWidgets('should_reset_local_progress_when_confirmed_in_settings_screen', (
    tester,
  ) async {
    final progressRepository = _FakeLocalProgressRepository();
    final settingsRepository = _FakeSettingsRepository(
      const PlayerSettings(soundEnabled: false, musicEnabled: true),
    );
    final controller = SettingsScreenController(
      getPlayerSettings: GetPlayerSettingsUseCase(settingsRepository),
      savePlayerSettings: SavePlayerSettingsUseCase(settingsRepository),
      resetLocalProgress: ResetLocalProgressUseCase(progressRepository),
    );

    await tester.pumpWidget(_TestSettingsApp(controller: controller));
    await tester.pump();

    await tester.tap(find.byKey(GameUiKeys.resetProgressButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(GameUiKeys.confirmResetProgressButton));
    await tester.pumpAndSettle();

    expect(progressRepository.resetCount, 1);
    expect(settingsRepository.settings.soundEnabled, isFalse);
    expect(settingsRepository.settings.musicEnabled, isTrue);

    controller.dispose();
  });
}

class _TestSettingsApp extends StatelessWidget {
  const _TestSettingsApp({required this.controller});

  final SettingsScreenController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: SettingsScreen(controller: controller),
    );
  }
}

class _FakeLocalProgressRepository implements LocalProgressRepository {
  int resetCount = 0;

  @override
  Future<LocalProgress> getProgress() async {
    return LocalProgress.initial();
  }

  @override
  Future<void> resetProgress() async {
    resetCount += 1;
  }

  @override
  Future<void> saveProgress(LocalProgress progress) async {}
}

class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this.settings);

  PlayerSettings settings;

  @override
  Future<PlayerSettings> getSettings() async {
    return settings;
  }

  @override
  Future<void> saveSettings(PlayerSettings settings) async {
    this.settings = settings;
  }
}
