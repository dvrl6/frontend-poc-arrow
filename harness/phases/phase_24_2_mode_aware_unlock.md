# PHASE 24.2 — Mode-Aware Level Unlock (Approach A)

Read before starting:
- `frontend-poc-arrow/docs/CODEX_HANDOFF.md`
- `frontend-poc-arrow/harness/context/current_constraints.md`

---

## Mandatory Pre-Implementation

Before writing any code:

1. Audit all files relevant to this task.
2. Explain your understanding of the current state.
3. State your confidence level. Must be ≥ 95% to proceed. If lower, ask clarifying questions.
4. **Wait for explicit approval before writing any code.**

> Note: a full audit (Phase 24.2 audit) already produced the trace below. Re-verify the key facts (especially that `progress3d.*` does NOT exist and that the leaderboard needs no change) before implementing.

---

## Background — Corrected Root Cause

**The `progress3d.*` namespace does not exist.** It is referenced only in docs (`docs/CODEX_HANDOFF.md`, `harness/phases/phase_24_game_mode_selector.md`), which are factually wrong. Storage is a single `progress.*` namespace in
`lib/features/progress/infrastructure/shared_preferences_local_progress_repository.dart`
(keys `progress.completedLevelNumbers`, `progress.bestResultsByLevel`, `progress.lastUnlockedLevel`).

Internal level numbering: 2D = 1–20, 3D = 21–25 (`AppConfig.manualLevelCount = 25`, `twoDLevelCount = 20`).

**Actual bug:** unlock is driven by a single scalar `LocalProgress.lastUnlockedLevel` (initial `1`) via
`isUnlocked(n) = n <= lastUnlockedLevel || isCompleted(n)`
(`lib/features/progress/domain/local_progress.dart:26-28`), and the level card gate calls
`progress.isUnlocked(levelNumber)` with the **internal** number
(`lib/features/levels/presentation/level_selection_screen.dart:110`).
For a fresh user `lastUnlockedLevel == 1`, so `isUnlocked(21)` is false → every 3D level is locked. The only way current logic unlocks internal 21 is by completing 2D level 20 (`unlockedCandidate = 20+1`), i.e. the two modes bleed through one shared counter.

**What is already correct (do NOT touch):**
- Leaderboard flow is fully mode-separated: picker filters by mode, and every fetch/submit resolves the unique internal number → backend id. No collision is possible (2D and 3D numbers never overlap). No leaderboard/API change is required.
- `hasNextLevelFor(internal, gameMode)` in `level_mode_filter.dart` already bounds "next level" per mode.

---

## Approach A — Specification

Compute unlock **per mode** from the existing shared `completedLevelNumbers` set. No new storage namespace, no migration. The shared set is naturally partitioned because internal numbers are globally unique.

Unlock rule for internal level `n` in mode `m`:

```
isLevelUnlockedForMode(progress, n, m) :=
    n == firstInternalLevelFor(m)          // 3D→21, 2D→1: first level of the mode is always unlocked
    OR progress.isCompleted(n - 1)         // previous internal level completed (same mode, since numbering is contiguous per mode)
```

Because 3D starts at internal 21 and its predecessor 20 is 2D, the `n == firstInternalLevelFor(m)` clause is what prevents cross-mode bleed for the first 3D level. For n = 22..25, `n-1` is always a 3D level, so `isCompleted(n-1)` is mode-correct. Symmetric for 2D (n=1 always unlocked; n=2..20 need n-1 completed).

Keep `lastUnlockedLevel` written by `SaveLevelCompletionUseCase` untouched (it stays for reset behavior / backward-compat) but it is no longer authoritative for the level-selection gate.

---

## Task

### 1. `lib/features/game/presentation/level_mode_filter.dart`
Add two helpers (presentation-layer, alongside the existing mode helpers):

```dart
/// First internal level number playable in [mode]: 1 for 2D, 21 for 3D.
int firstInternalLevelFor(GameMode mode) =>
    mode == GameMode.threeD ? twoDLevelCount + 1 : 1;

/// Mode-aware unlock: the first level of a mode is always unlocked; any later
/// level unlocks once the previous internal level was completed. Uses the
/// shared completedLevelNumbers set, which is naturally partitioned because
/// 2D (1-20) and 3D (21-25) internal numbers never overlap.
bool isLevelUnlockedForMode(
  LocalProgress progress,
  int internalLevel,
  GameMode mode,
) {
  if (internalLevel == firstInternalLevelFor(mode)) return true;
  return progress.isCompleted(internalLevel - 1);
}
```
Add the required import for `LocalProgress`.

### 2. `lib/features/levels/presentation/level_selection_screen.dart`
Replace line ~110:
```dart
final isUnlocked = progress.isUnlocked(levelNumber);
```
with:
```dart
final isUnlocked = isLevelUnlockedForMode(progress, levelNumber, gameMode);
```
`gameMode` is already in scope (read at ~line 75).

### 3. `lib/features/progress/domain/local_progress.dart` (optional overload)
Optionally add a mode-aware overload for domain-level testability, mirroring the helper logic. Keep the existing `isUnlocked(int)` for backward-compat. If added, the presentation helper may delegate to it. This is optional — do not duplicate the rule in two places without delegation.

### 4. `lib/features/progress/application/is_level_unlocked_use_case.dart`
Update for symmetry with the new mode-aware logic: accept a `GameMode` and apply the same rule (delegate to the domain overload or the shared helper). After updating, if it still has **zero production callers** (verify with a fresh grep), add a doc comment marking it deprecated/legacy but keep it for test coverage. Do not delete it.

### 5. Documentation corrections (remove the `progress3d.*` myth)
- `docs/CODEX_HANDOFF.md`: correct the lines (~1994, ~2002) that claim 3D completions are stored in a separate `progress3d.*` namespace. State the truth: a single `progress.*` namespace stores completions keyed by internal level number (1–25); mode separation for unlock is computed, not stored.
- `harness/phases/phase_24_game_mode_selector.md` (~line 117) and `harness/context/phase_registry.md` (~line 44): correct or annotate any `progress3d.*` reference. Do not rewrite history destructively — annotate/correct the factual claim.
- Grep the repo for `progress3d` and fix every remaining occurrence in docs.

---

## Constraints

- Do not modify `backend-poc-arrow` or any backend code.
- Do not modify auth, sync, leaderboard, or API code — the leaderboard is already mode-separated and requires no change.
- **No new storage namespace.** Do not introduce `progress3d.*` or any second `SharedPreferences` key set.
- **No migration.** No storage schema change.
- Do not change `SaveLevelCompletionUseCase` write logic or the `lastUnlockedLevel` scalar.
- Do not change `hasNextLevelFor` / next-level navigation (already correct).
- Do not modify Git remotes.
- Do not commit or push automatically.

---

## Test Plan

### New: `test/features/game/presentation/level_mode_filter_test.dart`
Cover `isLevelUnlockedForMode` (and `firstInternalLevelFor`):
- 3D level 1 (internal 21) unlocked by default with empty progress.
- 3D internal 22 locked until internal 21 completed; unlocked after.
- Completing 2D level 20 does **not** unlock 3D internal 21.
- Completing 3D internal 21 does **not** unlock 2D level 2.
- 2D level 1 unlocked by default; level 2 locked until 1 completed.

### New: widget regression test (level selection)
In 3D mode with empty progress, assert the first 3D card is unlocked/tappable and the remaining 3D cards are locked. Reuse existing `LevelSelectionScreen` test seams (`loadLevels`, `loadProgress`) and `AppSettingsScope` for `gameMode`.

### Update existing
- `test/features/progress/local_progress_test.dart`: if a mode-aware overload is added to `LocalProgress`, add cross-mode isolation assertions. Existing 2D assertions must still pass unchanged.
- If `IsLevelUnlockedUseCase` signature changes, update any test referencing it.

---

## Validation

Run these after implementation. All must pass.

```bash
flutter analyze
flutter test
node tool/gen_levels.js --validate-only   # only if level files were touched (they should NOT be)
```

---

## After Completion

1. Update `docs/CODEX_HANDOFF.md` using `harness/templates/handoff_update_template.md` (include the `progress3d.*` correction).
2. Update `harness/context/phase_registry.md`.
3. Update `harness/metrics/improvement_log.md`.

---

Do not be verbose. Be direct.
