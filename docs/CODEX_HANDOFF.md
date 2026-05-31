# Codex Handoff

## Current Repository

- Repository: `frontend-poc-arrow`
- Branch: `feat/frontend-backend-integration`
- Do not modify Git remotes automatically.
- Do not modify `backend-poc-arrow` unless a blocking API contract issue is found and reported first.

## Completed Phase

- Phase 8: Frontend Backend Integration.

Previous completed and merged phases:

- Phase 3 Flutter Bootstrap.
- Phase 4 Graph-Based Game Engine Domain.
- Phase 5 Manual Graph-Based Levels.
- Phase 6 Playable Game UI with Local Manual Levels.
- Phase 7 Local Progress, Level Unlocking, Settings, Audio Foundation, and UX Polish.

## Implemented Phase 8 State

- Added `http` as the only new dependency.
- Added `core/network` with `ApiClient`, `HttpApiClient`, and `ApiException`.
- Production HTTP uses injectable `http.Client`; no top-level `http.get`/`http.post` calls are used.
- Added optional auth:
  - Login/register use cases.
  - Auth API repository.
  - SharedPreferences token/session storage adapter.
  - Simple auth screen.
  - Settings login/logout status and actions.
- Added progress sync:
  - Remote progress repository.
  - Backend level-id mapping through `GET /levels`.
  - Merge policy that preserves better local progress.
  - Manual sync action in settings.
- Added leaderboard integration:
  - Fetch leaderboard for a backend level id.
  - Submit score after victory only when authenticated.
  - Leaderboard route opened from victory UI.
- Victory still saves local progress immediately and exactly once.
- Remote sync/leaderboard submission is best-effort and non-blocking.

## Architecture Decisions

- Local manual levels remain the default playable source.
- Remote levels are used only for backend `levelId` mapping and future compatibility.
- Auth is optional; logged-out users can play all local unlocked content.
- `SharedPreferences` token storage is allowed for Phase 8 academic/demo scope only.
- Production hardening should replace token storage with secure storage.
- HTTP access lives in `core/network` and infrastructure repositories.
- SharedPreferences access remains in infrastructure adapters.
- Screens/controllers do not directly call `http.Client` static helpers or `SharedPreferences`.
- Movement still goes through `GameSessionService`, `MoveArrowUseCase`, and `MovementResolver`.
- Gameplay remains graph-based; no matrix/grid-cell/tile runtime model was introduced.

## Progress Merge Policy

- Local progress remains the offline source of truth.
- Completed is true if either local or remote is completed.
- Best result policy:
  - Higher score is better.
  - If tied, fewer moves is better.
  - If tied, lower `timeSeconds` is better.
- Better local progress is never deleted because remote data is stale.
- If remote sync fails, local progress stays unchanged and usable.

## Leaderboard Behavior

- `POST /leaderboard` is attempted after victory only when authenticated and the backend level id can be resolved.
- `GET /leaderboard/:levelId` is used by the leaderboard screen.
- Leaderboard failures do not block victory, retry, next level, or back navigation.

## Local Fallback Behavior

- Backend unavailable: local level selection, gameplay, progress, unlocking, settings, and victory continue working.
- Auth unavailable: user can stay logged out and play locally.
- Remote level mapping unavailable: sync/leaderboard is skipped or reports unavailable, but local gameplay remains intact.

## Files Future Sessions Should Inspect First

- `lib/core/network/`
- `lib/features/auth/`
- `lib/features/progress/application/sync_progress_use_case.dart`
- `lib/features/progress/application/merge_progress_use_case.dart`
- `lib/features/progress/infrastructure/api_remote_level_repository.dart`
- `lib/features/progress/infrastructure/api_remote_progress_repository.dart`
- `lib/features/leaderboard/`
- `lib/features/settings/presentation/settings_screen.dart`
- `lib/features/game/presentation/game_screen_controller.dart`
- `test/core/network/http_api_client_test.dart`
- `test/features/auth/auth_integration_test.dart`
- `test/features/progress/progress_sync_test.dart`
- `test/features/leaderboard/leaderboard_submission_test.dart`
- `test/features/game/presentation/playable_game_ui_test.dart`

## Tests Added

- `should_login_user_when_credentials_are_valid`
- `should_store_token_when_login_succeeds`
- `should_attach_bearer_token_when_authenticated`
- `should_keep_local_progress_when_remote_progress_is_stale`
- `should_merge_remote_progress_when_remote_is_better`
- `should_submit_leaderboard_when_level_is_completed_and_user_is_authenticated`
- `should_skip_leaderboard_submission_when_user_is_not_authenticated`
- `should_keep_gameplay_available_when_backend_is_unreachable`
- Settings controller tests for logged-in/logout and sync failure behavior.

## Verification Results

- `flutter pub get`: passed.
- `flutter analyze`: passed with no issues.
- `flutter test`: passed with 51 tests.
- `docker compose up --build` from `backend-poc-arrow`: backend built and started successfully.
- `GET http://localhost:3000/health`: returned `status = ok`.
- `flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:3000`: debug app built, installed, and launched on Android emulator.
- Manual in-app register/login/complete-level interaction was not performed in this pass.
- Docker containers were stopped with `docker compose down` after the launch check.
- Backend repository remained untouched.
- Git remotes were not modified.

## Phase 9 — Gameplay Rules Fixes, Lives System, Level Redesign, Stability

Phase 9 corrected the core gameplay model, added a lives/game-over system, redesigned all 15 manual levels, added exit/collision animations, and fixed level-selection refresh. All work is inside `frontend-poc-arrow`; backend and Git remotes were untouched.

### Full Exit Attempt Rule

- Tapping an arrow performs a single, atomic **full exit attempt** — not one-step movement.
- The arrow head defines the exit direction; the arrow travels strictly in its head direction (it never auto-turns). If there is no neighbor in that direction, that part of the arrow leaves the board.
- The attempt either fully escapes or leaves the arrow exactly as it was. No partial movement is ever committed.

### Full-Arrow Collision Behavior

- Collision detection considers the arrow's **entire occupied shape**, not just the head.
- `MovementResolver.resolve` computes the moving arrow's full covered-node set (`coveredNodeIds`: start node, head node, and both endpoints of every occupied edge), and the union of covered nodes of all other active arrows.
- It sweeps a forward ray (graph adjacency) from **every** covered node. If any forward node is occupied by another active arrow, or any traversed edge is blocked, the attempt is a `collision`. Otherwise it is `escaped`.
- This means a body/segment overlap causes a collision even when the head's own path is clear.
- The resolver is read-only and lives in application; rules never live in presentation.

### Collision Rollback Behavior

- On collision, `MoveArrowUseCase` returns without mutating the arrow: same `endNodeId`, same `occupiedEdgeIds`. No partial movement remains.
- `movesCount` increments on every attempt (success or failure). `mistakeCount` increments only on failure.

### Lives / Mistakes / Game-Over Behavior

- Each session starts with 3 lives. `GameSession.livesRemaining = 3 - (mistakeCount ~/ 2)`.
- 0-1 mistakes = 3 lives, 2-3 = 2 lives, 4-5 = 1 life, 6+ = 0 lives.
- When lives reach 0 the use case sets `GameStatus.failed` and returns `MovementOutcome.gameOver`.
- Once `victory` or `failed`, further input is ignored (`sessionNotActive`).
- Retry (`GameScreenController.restart`) rebuilds via `GameSession.start`, resetting mistakes, lives, trace, and flash state.
- Score formula: `max(0, 1000 - (mistakeCount * 100) - (movesCount * 5))`. No timer; `elapsedSeconds` stays 0 and is not displayed.

### Exit Animation Behavior

- Rules resolve instantly in the domain; presentation animates the already-resolved trace.
- `GraphBoard` is stateful (`TickerProviderStateMixin`). When an arrow transitions active to escaped, it runs a ~360 ms controller that translates the **whole arrow shape** (all segments + head) outward in the head direction while fading — L/U/zigzag arrows move as one piece. After completion the arrow is rendered escaped/inactive.
- On collision it plays a short shake (sine nudge) plus the existing red collision flash, then the arrow snaps back.
- Graph nodes and edges remain visible at all times.
- `GameScreenController.lastAttemptTrace` (`GameAttemptTrace`) exposes arrow id + outcome for non-brittle tests.
- Animations are gated by `GameScreen.enableBoardAnimations` (default true; widget tests pass false to avoid ticker flakiness).

### Level Selection Refresh Fix

- `LevelSelectionScreen._openLevel` awaits `Navigator.pushNamed(...)` and reloads progress on return.
- Because the await completes on any pop (in-app button, app-bar back, Android system back), unlocked/completed/best-score state is always refreshed after returning from a level.

### Redesigned Manual Levels

- All 15 levels in `assets/levels/manual_levels.json` were redesigned as deterministic, graph-based, varied-shape levels: L-shaped, narrow corridor, gapped lanes, staircase, plus/cross, T, branch/tree, H-ladder, and asymmetric multi-arm.
- Preserved: exactly 15 levels, numbers 1-15, difficulty progression (1-5 easy, 6-10 medium, 11-15 hard), and the existing graph-based JSON schema.
- `blockedEdges` is empty for all 15 levels; the main blocker is other active arrows. No matrix/grid/tile runtime logic.
- Hard levels 11-15 are not all rectangles (0 of them are full rectangles).
- All 15 pass `LevelDefinitionValidator` and remain solvable under the full-exit resolver.

### No-Free-Nodes Rule

- At the start of every level, every graph node is occupied by at least one arrow (via start node, head node, or an occupied edge endpoint).
- Validated both by the generator and by the Dart test `should_have_no_free_nodes_at_level_start`.

### tool/gen_levels.js Purpose

- A deterministic Node generator/validator for the 15 manual levels. It builds levels from straight/L "filled corridors," then verifies structure (orthogonal edges, unique ids, arrow edges/nodes exist), no-free-nodes, difficulty progression, hard-not-all-rectangular, and full-exit solvability (DFS using a JS mirror of the Dart resolver). It writes `assets/levels/manual_levels.json` only when every check passes. It is a build-time authoring tool, not runtime code, and does not perform random generation.

### Tests Added / Updated

- `exit_attempt_resolver_test.dart`: full-shape head and body collision, clear-sweep escape, multi-segment escape, blocked edge, self-non-collision, already-escaped (3x2 grid fixture added).
- `move_arrow_use_case_test.dart`: escape, collision + rollback (state unchanged), blocked edge, lives table, game-over trigger, guards, score formula.
- `lives_system_test.dart`: lives thresholds, game-over, restart reset.
- `score_calculator_test.dart`: new mistake/move formula, no time penalty.
- `manual_levels_test.dart`: `should_have_no_free_nodes_at_level_start`, all-levels-solvable (DFS via real resolver), hard-not-all-rectangular, graph-based (no matrix/grid/cells keys), difficulty progression, level mapping.
- `game_screen_controller_test.dart` (new): escape trace, collision trace + flash, restart resets trace/lives/mistakes.
- `playable_game_ui_test.dart`: lives HUD, game-over overlay, graph persistence after exit, backend-unreachable, locked level, and `should_refresh_progress_when_returning_from_game`.

### Phase 9 Verification Results

- `flutter analyze`: passed with no issues.
- `flutter test`: passed, 92 tests.
- `node tool/gen_levels.js`: all 15 levels valid, no free nodes, all solvable, 0 hard rectangles; asset written.
- Manual emulator validation: not yet performed in this pass — see checklist below. Backend repository and Git remotes were not modified.

### Phase 9 Manual Emulator Validation (pending)

1. Tap an L/zigzag arrow with a clear path: whole shape slides out as one piece; nodes/edges remain.
2. Tap a blocked arrow: short shake + red flash, snaps back, no partial movement, mistake +1.
3. Confirm full-shape blocking where a body segment (not the head) is the blocker.
4. Lives deplete every 2 mistakes; game-over at 6; Retry resets to 3 lives.
5. Complete a level, return via system back and app-bar back: next level shows unlocked both ways.
6. Play all 15 levels to confirm documented solution orders and non-rectangular shapes render.
7. Backend up: login -> complete -> sync/leaderboard non-blocking. Backend down: full local play intact.

## Known Limitations

- No random level generation yet.
- No final APK build yet.
- No production deployment config.
- No full account/profile management.
- Token storage uses SharedPreferences for academic/demo scope; secure storage is future work.
- Remote levels do not replace local gameplay.
- No final music/background audio assets yet.
- No real gameplay timer yet (intentional; score is mistake/move based).
- Stuck/deadlock detection was treated as optional and is not implemented; lives/game-over remains the failure path.
- Phase 9 manual emulator validation is still pending.

## Next Recommended Phase

Recommended next phase: final release preparation and a manual backend/emulator smoke test (auth, sync, leaderboard against the Docker backend), then optionally random graph-based level generation. Complete the Phase 9 manual emulator checklist before starting new feature work.
