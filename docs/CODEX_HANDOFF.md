# Codex Handoff

## Current Repository

- Repository: `frontend-poc-arrow`
- Branch: `feat/frontend-bootstrap`
- Do not modify Git remotes automatically.
- Do not modify `backend-poc-arrow` from this frontend phase.

## Completed Phase

Phase 3 Flutter Bootstrap is complete.

This phase created the Flutter app foundation only. It did not implement gameplay, manual levels, random levels, or backend integration.

## Implemented Foundation

- Flutter Android project initialized with package name `frontend_poc_arrow`.
- Clean Architecture folder scaffold created under `lib/core` and `lib/features`.
- Home screen implemented.
- Level selection placeholder screen implemented.
- Game placeholder screen implemented.
- Settings placeholder screen implemented.
- Named routing implemented in `lib/core/routing/app_routes.dart`.
- Dark/neon UI foundation implemented in `lib/core/theme/app_theme.dart`.
- `DottedBoardPlaceholder` implemented as a presentation-only visual placeholder.
- API config implemented in `lib/core/config/app_config.dart`.
- API base URL uses `String.fromEnvironment`.
- Default API URL: `http://10.0.2.2:3000`.
- English and Spanish localization configured.
- `l10n.yaml` and ARB files added.
- Basic widget tests added.
- Flutter GitHub Actions workflow added.
- `README.md` and `AI_USAGE.md` updated.

## Important Constraints

- Do not implement the game engine in Phase 3.
- `DottedBoardPlaceholder` is not the game engine.
- No `BoardGraph`, `GraphNode`, `GraphEdge`, `ArrowPath`, movement, score, victory/defeat, manual levels, random levels, or backend integration were implemented.
- Flutter will own gameplay logic in future phases.
- Backend does not process every move.
- Future game board must be graph-based, not matrix-only.

## Current Structure

```text
lib/
  core/
    config/
    errors/
    localization/
    routing/
    theme/
    network/
    storage/
  features/
    game/
      domain/
      application/
      infrastructure/
      presentation/
    auth/
    levels/
    leaderboard/
    settings/
```

Empty `.gitkeep` files preserve future Clean Architecture folders. Do not treat those folders as implemented feature logic.

## Localization

Localization files and config:

- `l10n.yaml`
- `lib/core/localization/l10n/app_en.arb`
- `lib/core/localization/l10n/app_es.arb`
- Generated localization files under `lib/core/localization/l10n`

Current localized strings include app title, Play, Settings, Levels, game placeholder, and backend URL label.

## API Configuration

API config lives only in:

```text
lib/core/config/app_config.dart
```

Current implementation:

```dart
String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000',
)
```

Do not hardcode backend URLs inside screens, domain logic, use cases, or future infrastructure classes.

## Backend Context

Backend repo: `backend-poc-arrow`.

Backend endpoints already exist, but Phase 3 does not integrate them yet.

Android Emulator backend URL:

```text
http://10.0.2.2:3000
```

Dart define override:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

## Verification Results

- `flutter pub get`: passed.
- `flutter analyze`: passed.
- `flutter test`: passed.
- Android Emulator manual run: passed.
- App opened successfully.
- Home screen displayed the backend URL.
- Placeholder UI worked.

## Notes

- First `flutter create --platforms=android .` command failed because `frontend-poc-arrow` is not a valid Dart package name.
- The project was created successfully with `flutter create --platforms=android --project-name frontend_poc_arrow .`.
- Existing `AI_USAGE.md` was preserved after `flutter create`.
- `flutter run -d windows` failed because the project was generated for Android only.
- The Windows run failure is not a project issue.
- `mocktail` was not added because Phase 3 tests do not use mocks.

## Commands

```powershell
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

## Next Recommended Phase

Phase 4: Graph-Based Game Engine Domain.

Recommended Phase 4 approach:

- Implement pure Dart domain classes first.
- Add tests before UI/gameplay integration.
- Keep the runtime board graph-based.
- Verify that graph nodes remain visible when arrows eventually exit.
- Do not move gameplay/movement responsibility to the backend.

## Files Future Codex Sessions Should Inspect First

- `README.md`
- `AI_USAGE.md`
- `pubspec.yaml`
- `l10n.yaml`
- `lib/main.dart`
- `lib/core/config/app_config.dart`
- `lib/core/routing/app_routes.dart`
- `lib/core/theme/app_theme.dart`
- `lib/features/game/presentation/dotted_board_placeholder.dart`
- `test/widget_test.dart`
