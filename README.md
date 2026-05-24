# Arrow POC Frontend

Flutter mobile app for the Arrow Maze inspired semester project.

## Current Phase

Phase 8 adds optional backend integration on top of the local-first playable graph UI.

The normal user flow supports:

- Opening the app and entering level selection.
- Viewing the 15 local manual levels.
- Seeing locked, unlocked, and completed level states.
- Selecting a level.
- Rendering the graph board with persistent nodes and edges.
- Rendering active arrow paths over graph edges.
- Tapping arrows to activate movement through the existing game engine.
- Updating moves and score.
- Saving completion locally when victory is reached.
- Showing victory, retry, back-to-levels, best score, and next-level actions.
- Resetting local progress from settings without clearing sound/music settings.
- Registering or logging in optionally to enable progress sync and leaderboard features.
- Keeping local gameplay available when the backend is unreachable.

Local levels are stored at:

```text
assets/levels/manual_levels.json
```

The asset mirrors the backend seed shape as closely as possible:

```json
{
  "levels": [
    {
      "number": 1,
      "name": "First Exit",
      "difficulty": "easy",
      "definitionJson": {
        "nodes": [],
        "edges": [],
        "arrows": [],
        "blockedEdges": [],
        "metadata": {}
      }
    }
  ]
}
```

Phase 8 does not implement random level generation, final APK preparation, production deployment config, full account/profile management, secure token storage hardening, or final music assets.

## Architecture Direction

The frontend follows Clean Architecture:

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

Domain and application code in `features/game` is pure Dart. It does not import Flutter widgets, BuildContext, HTTP, storage, assets, or generated localization.

## Critical Gameplay Boundary

Flutter owns the playable game engine.

The backend stores and serves users, graph-based levels, progress, and leaderboard data. The backend must not process every player move.

The runtime game model is graph-based, not matrix-only:

- Graph nodes represent visible dots.
- Graph edges represent valid paths between dots.
- Arrows are dynamic multi-segment paths over graph edges.
- When an arrow exits, the arrow becomes escaped/inactive, but graph nodes and edges remain intact.

`DottedBoardPlaceholder` is presentation-only and is not the game engine.

## Game Engine Domain

Main domain concepts:

- `BoardGraph`
- `GraphNode`
- `GraphEdge`
- `BoardCoordinate`
- `Direction`
- `ArrowPath`
- `ArrowSegment`
- `Level`
- `GameSession`
- `GameStatus`
- `Score`

Main application concepts:

- `MoveArrowCommand`
- `MoveArrowUseCase`
- `MovementResolver`
- `CollisionDetector`
- `CheckVictoryUseCase`
- `ScoreStrategy`
- `ScoreCalculator`
- `GameSessionService`
- `LevelRepository`
- `GetLocalLevelsUseCase`
- `GetLocalLevelByNumberUseCase`

Main infrastructure concepts:

- `LocalLevelDataSource`
- `AssetLevelRepository`
- `LevelDefinitionMapper`
- `RootBundleAssetTextLoader`
- `LocalLevelDependencies`

Main presentation concepts:

- `LevelSelectionScreen`
- `GameScreen`
- `GameScreenController`
- `GraphBoard`
- `GraphBoardPainter`
- `GraphBoardLayout`
- `GraphBoardHitTester`

## Local Progress and Unlocking

Local progress is persisted with `shared_preferences`, behind Clean Architecture ports/adapters:

- `LocalProgressRepository` is the application port.
- `SharedPreferencesLocalProgressRepository` is the infrastructure adapter.
- `GetLocalProgressUseCase`, `SaveLevelCompletionUseCase`, `IsLevelUnlockedUseCase`, `GetBestLevelResultUseCase`, and `ResetLocalProgressUseCase` are the application entry points.

Unlocking is intentionally simple:

- Level 1 is unlocked by default.
- Completing level N unlocks level N + 1.
- Completed levels remain playable.
- Locked levels are disabled in level selection and show a short message when tapped.

Best local result uses the same semantics as the backend:

- Higher score is better.
- If score is tied, fewer moves is better.
- If moves are tied, lower `timeSeconds` is better.

Phase 7 stores `timeSeconds = 0` because a real gameplay timer is not implemented yet; the UI does not display a fake timer.

## Settings and Audio Foundation

The settings screen now supports:

- Sound feedback enabled/disabled.
- Music enabled/disabled as a stored preference only.
- Read-only language display.
- Read-only API base URL display.
- Reset local progress with confirmation.

Reset progress clears completed levels, best results, and unlock state only. It does not clear sound, music, language, or API URL configuration.

Audio is a foundation only. Phase 7 uses lightweight Flutter system click feedback for movement/block/victory events when sound is enabled. Final sound effects, background music, and approved audio assets remain future work.

## Backend Integration

Backend integration is optional and local-first:

- Local manual levels from `assets/levels/manual_levels.json` remain the default playable source.
- Authentication is optional. Login/register enables progress sync and leaderboard submission only.
- Backend failures never block victory, retry, next level, back navigation, or local progress.
- Remote levels are used only to map local level numbers to backend `levelId` values for progress and leaderboard APIs.

The frontend uses a small `core/network` abstraction over an injectable `http.Client`. Production code does not call top-level `http.get` or `http.post`; API calls go through repositories and use cases.

Auth stores the JWT and basic user summary in `SharedPreferences` for Phase 8 academic/demo scope. Production hardening should replace this with secure token storage.

Progress sync uses this merge policy:

- Completed remains true if either local or remote says completed.
- Higher score is better.
- If score is tied, fewer moves is better.
- If moves are tied, lower `timeSeconds` is better.
- Better local progress is never deleted because remote data is stale.

Leaderboard behavior:

- After victory, the app saves local progress immediately.
- If the user is logged in, the app attempts progress sync and leaderboard submission in the background.
- If submission fails, local gameplay remains complete and usable.

## Movement Semantics

Phase 4 movement is intentionally simple and deterministic:

- An arrow moves from its head/end node in its current direction.
- `BoardGraph.getNeighbor(nodeId, direction)` works from either endpoint of an undirected edge.
- If the next edge is blocked, the arrow does not move.
- If another active arrow occupies the target edge, the arrow does not move.
- If no neighbor exists in the arrow direction, the move is treated as an exit.
- Escaped arrows remain stored with `isEscaped = true`, but are inactive and do not block collisions.
- If all arrows escape, the session status becomes `victory`.

The UI does not implement movement rules. It selects an arrow id from a tap and delegates movement to `GameSessionService`, which uses the existing application/domain services.

## Graph Rendering

The board is rendered from graph entities only:

- `BoardGraph.nodes` provide persistent visible dots.
- `BoardGraph.edges` provide guide paths and blocked-edge accents.
- `ArrowPath.occupiedEdgeIds` provide active arrow path segments.

`GraphBoardLayout` centralizes graph-coordinate to canvas-coordinate mapping for both painting and hit testing. It lives in presentation and is not domain logic.

Escaped arrows are skipped when rendering active arrows, but graph nodes and edges remain visible.

## Level Validation

`LevelDefinitionValidator` performs structural validation only:

- Unique node ids.
- Unique edge ids.
- Edge endpoints reference existing nodes.
- Edges are orthogonal.
- Unique arrow ids.
- Arrow occupied edges exist.
- Arrow start/end nodes exist.
- Blocked edge ids exist.
- Metadata exists.

It does not solve puzzles, validate beatability, generate random levels, or create the 15 manual levels.

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

## Running Locally

```powershell
flutter pub get
flutter analyze
flutter test
flutter run
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

- Add random graph-based levels only after the manual playable path is stable.
- Add real timer support if time-based scoring should be presented in the UI.
- Add approved final sound effects/background music assets.
- Harden token storage for production builds.
- Prepare Android APK near final delivery.

## Commit Convention

Use Conventional Commits in English:

```text
feat(game): add graph-based engine domain
feat(levels): add local manual graph levels
feat(game): add playable graph board ui
feat(progress): add local level unlocking and settings
feat(integration): add optional backend auth and sync
test(game): add movement and graph validation tests
docs(frontend): document game engine domain
```
