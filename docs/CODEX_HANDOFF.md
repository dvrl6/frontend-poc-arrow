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

## Known Limitations

- No random level generation yet.
- No final APK build yet.
- No production deployment config.
- No full account/profile management.
- Token storage uses SharedPreferences for academic/demo scope; secure storage is future work.
- Remote levels do not replace local gameplay.
- No final music/background audio assets yet.
- No real gameplay timer yet.

## Next Recommended Phase

Recommended next phase: random graph-based levels or final release preparation, after a manual backend/emulator smoke test validates auth, sync, and leaderboard against Docker backend.
