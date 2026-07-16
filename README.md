# Nodus

Flutter graph-based puzzle game. Player-facing client only — see `backend-poc-arrow` for the server.

## What it is

Nodus is a graph-based puzzle game: each level is a graph of nodes and edges covered by rigid arrows. Tapping an arrow attempts a full exit in its head direction; the arrow either escapes the board entirely or the move is rolled back. The game ships 2D and 3D level sets, with an optional online account for progress sync and leaderboards.

## Tech stack

- Flutter / Dart
- Clean Architecture (Domain → Application → Infrastructure → Presentation)

## Architecture

```text
lib/
  core/                  cross-cutting concerns
    app/
    config/
    network/
    routing/
    storage/
    theme/
    localization/
    errors/
  features/
    <feature>/
      domain/            entities, value objects, pure Dart rules
      application/        use cases, ports, services
      infrastructure/     adapters: HTTP, SharedPreferences, assets
      presentation/       screens, controllers, widgets
```

Every feature (`game`, `auth`, `levels`, `progress`, `leaderboard`, `settings`, `challenges`, `home`, `audio`) follows the same four-layer split under `lib/features/<feature>/`. Domain and application code stays pure Dart — no Flutter, HTTP, or storage imports.

## Project structure

```text
lib/
  core/
  features/
assets/
  audio/       sound effects and background music
  fonts/
  levels/      manual_levels_2d.json, manual_levels_3d.json
test/
tool/          level generator/validator (gen_levels.js)
docs/
harness/
```

## Key features

- Graph-based gameplay: full-exit arrow attempts, lives/game-over
- 2D and 3D game modes, switchable from the home screen; each mode has its own level progression
- 30 levels total: 2D 1–20 (15 random-layout tiers + 5 figure silhouettes — heart, diamond, club, spade, crown), 3D 21–30 (10 multi-layer figures — pyramid, diamond, hourglass, cross, starburst, cat, helix, hollow pyramid, and more)
- Dynamic difficulty: level order, display numbers, and unlocking are driven by a computed complexity score per level (not a fixed/authored difficulty field), separately for each mode
- Challenges: Time Attack, Move Limit, and Perfect Run modifiers over existing levels, with calculated limits and fully separate best-score tracking (no effect on campaign progress, unlocks, or sync)
- Audio: sound effects and background music via an app-lifetime audio manager (survives navigation, ducks correctly, pauses/resumes with app lifecycle)
- Optional auth: login/register, logged-out play fully supported
- Progress: local-first, with optional remote sync
- Leaderboard: per-level scores when authenticated
- Settings: sound, music, language
- Backend-driven dynamic levels: additional real levels served by the backend, merged into the local list (offline-first, feature-flagged, off by default)

## Setup

```powershell
flutter pub get
flutter gen-l10n
```

Point the app at a backend with the `API_BASE_URL` dart-define (Android emulator example):

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

## Backend-driven dynamic levels

The 30 bundled levels (`assets/levels/manual_levels_2d.json`, `manual_levels_3d.json`) are always the offline source of truth and load with no backend dependency. On top of them, the backend can serve additional real, playable levels (number band `>= 1000`) that the app downloads and merges at runtime — see `backend-poc-arrow/docs/DYNAMIC_LEVELS_CONTRACT.md` for the full contract.

- Off by default — enable with `--dart-define=ENABLE_REMOTE_LEVELS=true` (`lib/core/config/app_config.dart`).
- `MergedLevelRepository` (`lib/features/game/infrastructure/`) loads local levels first, best-effort fetches remote levels, and appends any whose number isn't already local; local always wins on a numbering conflict.
- The last successful fetch is cached (`RemoteLevelCache`, SharedPreferences) so remote levels stay playable offline after the first successful sync.
- A network failure, empty response, or backend outage never breaks local level selection, gameplay, unlocking, sync, or the leaderboard.
- 2D vs 3D routing for merged levels is decided purely by graph shape (`boardGraph.isMultiLayer`), not by number.
- The remote-levels default is currently off because several widget tests don't inject a fake level loader and would hit the network under `flutter test` if it defaulted on — see `docs/LEVEL_AUTHORING.md` §17 and `harness/context/phase_registry.md` (Phase 34.5) for details.

## Run

```powershell
flutter run
flutter test
flutter analyze
```

Run with backend-driven dynamic levels enabled:

```powershell
flutter run --dart-define=ENABLE_REMOTE_LEVELS=true --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

## Level authoring / validation

```powershell
node tool/gen_levels.js --validate-only   # default; reads and checks only, never writes
node tool/gen_levels.js --generate-2d
node tool/gen_levels.js --generate-3d
node tool/gen_levels.js --generate        # runs both generators
```

`assets/levels/manual_levels_2d.json` (levels 1–20) and `assets/levels/manual_levels_3d.json` (levels 21–30) are the authoritative, tool-validated level data. Internal level numbers are storage/routing/leaderboard keys only — in-app display order and level numbers come from the computed difficulty progression, not from these files' order or their (dormant) `difficulty` field.

## Notes

- The `PixelGame` display font (`assets/fonts/PixelGame.otf`, used for the wordmark, mode toggle, and victory/game-over titles) is licensed 1001Fonts FFP — personal use only. A commercial release requires the author's written permission.
