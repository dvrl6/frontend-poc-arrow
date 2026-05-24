# Arrow POC Frontend

Flutter mobile app foundation for the Arrow Maze inspired semester project.

## Current Phase

Phase 3 frontend bootstrap is focused on project foundation only:

- Flutter Android project setup.
- Clean Architecture folder scaffold.
- Placeholder home, levels, game, and settings screens.
- Named routing.
- Dark neon visual foundation.
- English and Spanish localization.
- API base URL configuration.
- Basic widget tests.
- Flutter GitHub Actions workflow.

This phase does not implement the game engine, manual levels, random levels, score logic, victory/defeat rules, or full backend integration.

## Architecture Direction

The frontend will follow Clean Architecture:

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

The current empty layer folders are intentional placeholders for future phases.

## Critical Gameplay Boundary

Flutter owns the playable game engine.

The backend stores and serves users, graph-based levels, progress, and leaderboard data. The backend must not process every player move.

Future gameplay must use a persistent graph-based board model, not a matrix-only runtime model. The current `DottedBoardPlaceholder` is presentation-only and is not a game engine.

## Backend URL

The default API base URL is configured in `lib/core/config/app_config.dart`:

```dart
String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000',
)
```

Android Emulator note: use `http://10.0.2.2:3000` to reach a backend running on the host machine.

Override example:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

## Localization

Localization is configured with:

- `l10n.yaml`
- `lib/core/localization/l10n/app_en.arb`
- `lib/core/localization/l10n/app_es.arb`

Current languages:

- English
- Spanish

## Running Locally

```powershell
flutter pub get
flutter analyze
flutter test
flutter run
```

Run with an explicit backend URL:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

## CI

GitHub Actions workflow:

```text
.github/workflows/flutter.yml
```

It runs:

- `flutter pub get`
- `flutter analyze`
- `flutter test`

## Next Phases

Recommended next work:

- Build the graph-based game domain model.
- Add local manual level assets mirroring backend graph JSON.
- Implement arrow movement, exit handling, graph persistence, score logic, and tests.
- Add backend integration for auth, levels, progress, and leaderboard.
- Prepare Android APK near final delivery.

## Commit Convention

Use Conventional Commits in English:

```text
feat(frontend): bootstrap flutter app foundation
test(frontend): add startup and routing widget tests
docs(frontend): document flutter bootstrap
```
