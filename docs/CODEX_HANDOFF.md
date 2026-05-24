# Codex Handoff

## Current Repository

- Repository: `frontend-poc-arrow`
- Branch: `feat/local-progress-settings-audio`
- Do not modify Git remotes automatically.
- Do not modify `backend-poc-arrow` from this frontend phase.

## Completed Phase

- Phase 7: Local Progress, Level Unlocking, Settings, Audio Foundation, and UX Polish.

Previous completed and merged phases:

- Phase 3 Flutter Bootstrap.
- Phase 4 Graph-Based Game Engine Domain.
- Phase 5 Manual Graph-Based Levels.
- Phase 6 Playable Game UI with Local Manual Levels.

## Files and Features Added

- Local progress domain model:
  - `lib/features/progress/domain/local_progress.dart`
  - `lib/features/progress/domain/level_best_result.dart`
- Local progress application ports/use cases:
  - `LocalProgressRepository`
  - `GetLocalProgressUseCase`
  - `SaveLevelCompletionUseCase`
  - `IsLevelUnlockedUseCase`
  - `GetBestLevelResultUseCase`
  - `ResetLocalProgressUseCase`
  - `BestLevelResultPolicy`
- SharedPreferences progress adapter:
  - `SharedPreferencesLocalProgressRepository`
  - `LocalProgressDependencies`
- Settings model/repository/use cases:
  - `PlayerSettings`
  - `SettingsRepository`
  - `GetPlayerSettingsUseCase`
  - `SavePlayerSettingsUseCase`
  - `SharedPreferencesSettingsRepository`
  - `SettingsDependencies`
- Settings UI:
  - `SettingsScreen`
  - `SettingsScreenController`
- Audio foundation/facade:
  - `AudioPort`
  - `GameAudioEvent`
  - `GameAudioController`
  - `SystemSoundAudioPort`
  - `AudioDependencies`
- UI integrations:
  - Level selection shows locked, unlocked, completed, and best-score states.
  - Locked levels show a snackbar and do not navigate.
  - Victory flow saves progress exactly once per completed game session.
  - Victory card shows best score when available.
  - Settings screen includes sound/music toggles, read-only API URL/language display, and reset progress confirmation.
- Tests added for progress, settings, audio foundation, locked levels, and level-selection refresh.

## Architecture Decisions

- `shared_preferences` is the only dependency added in Phase 7.
- `SharedPreferences` is used only in infrastructure/adapters.
- Screens, controllers, widgets, painters, domain classes, and game application services do not call `SharedPreferences` directly.
- Domain remains free of Flutter, storage, HTTP, assets, localization, and widget dependencies.
- Movement still goes through `GameSessionService`, `MoveArrowUseCase`, and `MovementResolver`.
- Gameplay remains graph-based: UI renders `BoardGraph.nodes`, `BoardGraph.edges`, and `ArrowPath.occupiedEdgeIds`.
- No matrix, grid-cell, tile, or cell-runtime model was introduced.

## Progress Behavior

- Level 1 is unlocked by default.
- Completing level N unlocks level N + 1, capped by the available manual level count.
- Completed levels remain playable.
- Progress stores:
  - completed level numbers
  - best results by level
  - last unlocked level
- Best-result policy:
  - Higher score is better.
  - If score is tied, fewer moves is better.
  - If moves are tied, lower `timeSeconds` is better.
- `timeSeconds` is currently `0` until real timer support exists.
- The UI intentionally does not show a fake live timer or fake best time.

## Settings Behavior

- Sound setting persists locally.
- Music setting persists locally for future music support.
- Reset progress clears completed levels, best results, and unlock state only.
- Reset progress does not reset sound/music settings.
- API base URL remains read-only and config driven through `AppConfig.apiBaseUrl`.
- Language display is read-only; runtime language switching was not implemented in Phase 7.

## Audio Behavior

- Audio is foundation only.
- `GameAudioController` checks `soundEnabled` before delegating playback.
- `SystemSoundAudioPort` uses lightweight Flutter system click feedback.
- Final sound effects, background music, and approved audio assets are not complete.
- No `audioplayers` dependency was added.
- No fake or empty audio assets were added.

## Tests Added

- `should_unlock_level_one_by_default`
- `should_unlock_next_level_when_current_level_is_completed`
- `should_save_best_score_when_new_score_is_better`
- `should_keep_existing_best_score_when_new_score_is_worse`
- `should_persist_sound_setting_when_toggled`
- `should_reset_local_progress_when_confirmed`
- `should_reset_local_progress_when_confirmed_in_settings_screen`
- `should_play_audio_feedback_when_sound_is_enabled`
- `should_not_play_audio_feedback_when_sound_is_disabled`
- `should_not_open_locked_level_when_level_is_locked`
- `should_update_level_selection_after_level_completion`

## Verification Results

- `flutter pub get`: passed.
- `flutter analyze`: passed with no issues.
- `flutter test`: passed with 41 tests.
- Manual emulator run: not performed in this pass because no Android emulator was detected by `flutter devices`.
- `flutter devices` showed Windows desktop, Chrome, and Edge only.
- Backend repository remained untouched.
- Git remotes were not modified.

## Known Limitations

- No backend authentication, progress sync, remote levels, or leaderboard integration yet.
- No random level generation yet.
- No final APK build yet.
- No final music/background audio assets yet.
- No real gameplay timer yet.
- Settings language display is read-only.
- Music preference is persisted only; it does not play music yet.

## Files Future Sessions Should Inspect First

- `lib/features/progress/application/`
- `lib/features/progress/domain/`
- `lib/features/progress/infrastructure/`
- `lib/features/settings/presentation/settings_screen.dart`
- `lib/features/settings/presentation/settings_screen_controller.dart`
- `lib/features/settings/infrastructure/shared_preferences_settings_repository.dart`
- `lib/features/audio/application/game_audio_controller.dart`
- `lib/features/audio/infrastructure/system_sound_audio_port.dart`
- `lib/features/levels/presentation/level_selection_screen.dart`
- `lib/features/game/presentation/game_screen.dart`
- `lib/features/game/presentation/game_screen_controller.dart`
- `test/features/progress/local_progress_test.dart`
- `test/features/settings/settings_test.dart`
- `test/features/audio/audio_controller_test.dart`
- `test/features/game/presentation/playable_game_ui_test.dart`

## Next Recommended Phase

Recommended next phase: backend integration for authentication, remote level retrieval, progress synchronization, and leaderboard submission while preserving local offline play.
