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
- Audio: sound effects and background music
- Optional auth: login/register, logged-out play fully supported
- Progress: local-first, with optional remote sync
- Leaderboard: per-level scores when authenticated
- Settings: sound, music, language
- Challenges: separate from campaign progress
- 3D level mode alongside 2D

## Setup

```powershell
flutter pub get
flutter gen-l10n
```

Point the app at a backend with the `API_BASE_URL` dart-define (Android emulator example):

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

## Run

```powershell
flutter run
flutter test
flutter analyze
```

## Level authoring / validation

```powershell
node tool/gen_levels.js --validate-only   # default; reads and checks only, never writes
node tool/gen_levels.js --generate-2d
node tool/gen_levels.js --generate-3d
node tool/gen_levels.js --generate        # runs both generators
```

`assets/levels/manual_levels_2d.json` (levels 1–20) and `assets/levels/manual_levels_3d.json` (levels 21+) are the authoritative, tool-validated level data.
