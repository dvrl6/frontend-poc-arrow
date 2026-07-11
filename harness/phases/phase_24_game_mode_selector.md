# PHASE 24 — Game Mode Selector (2D/3D) + "Challenges" Rebrand

Read before starting:
- `frontend-poc-arrow/docs/CODEX_HANDOFF.md`
- `frontend-poc-arrow/harness/context/current_constraints.md`

---

## Git Context

- Base branch: `main`.
- Current working branch `feat/phase-24-game-mode-selector`. Stay on it.
- Do **not** modify Git remotes.
- Do **not** commit or push automatically. Stage only if ≥ 95% confident; manual audit required.

---

## Mandatory Pre-Implementation

Before writing any code:

1. Audit all files listed under each task.
2. Explain your understanding of the current state (menu button wiring, `PlayerSettings`/`languageCode` persistence pattern, `AppSettingsController`/`AppSettingsScope` reactivity, level filtering seams).
3. State your confidence level. Must be ≥ 95% to proceed. If lower, ask clarifying questions.
4. **Wait for explicit approval before writing any code.**

---

## Background

The main menu (`lib/features/home/presentation/home_screen.dart`) renders four buttons: **Levels**, **Leaderboard**, **Settings**, and a disabled fourth button labelled `localizations.gameMode` ("Game Mode") with `onPressed: null`. Challenge levels do not exist, so that button must stay disabled — it is only being **relabelled** to "Challenges" / "Retos".

Separately, the app already ships 2D levels (1–20) and 3D/multi-layer levels (21–25). 3D levels are identifiable in presentation via `level.boardGraph.isMultiLayer` (`BoardGraph.isMultiLayer => layers.length > 1`) or `level.number >= 21`. ~~Progress namespaces are already separated (`progress.*` for 2D, `progress3d.*` for 3D).~~ **[Correction — Phase 24.2: this was factually wrong. There is only one `progress.*` namespace keyed by internal level number (1-25); `progress3d.*` never existed. Mode-separated unlock is computed, not stored.]** There is currently **no user control** over which mode the menu targets. This phase adds a persisted 2D/3D selector in Settings that drives the Levels and Leaderboard menu buttons and filters the level lists at the presentation layer only.

Follow the existing `languageCode` pattern end-to-end: it is the reference implementation for "persist a `PlayerSettings` field + drive reactive app-level UI via `AppSettingsController`/`AppSettingsScope`".

---

## Task A — Rename "Game Mode" → "Challenges" (Retos)

Pure localization/label change. The button stays disabled.

**Files to audit:**
- `lib/features/home/presentation/home_screen.dart` (the fourth `_MenuNavButton`, currently `label: localizations.gameMode`, `onPressed: null`).
- `lib/core/localization/l10n/app_en.arb`, `app_es.arb` (`gameMode` key).

**Required:**
- Add a new localization key `challenges` — EN `"Challenges"`, ES `"Retos"` — to both ARB files (with a `@challenges` metadata entry matching the file's convention).
- Point the disabled button's `label` at `localizations.challenges`.
- Keep `onPressed: null` (disabled). Do **not** wire a route.
- Do **not** delete the `gameMode` key — Task B reuses it as the Settings selector title ("Game Mode" / "Modo de juego"). Update `gameMode`'s ES value if it is currently wrong; EN stays `"Game Mode"`.

---

## Task B — 2D/3D Game Mode Selector in Settings

Add a persisted, reactive 2D/3D selector, mirroring the `languageCode` implementation exactly.

### B1 — Domain: persist the mode on `PlayerSettings`

**Files to audit:**
- `lib/features/settings/domain/player_settings.dart`
- `lib/features/settings/infrastructure/shared_preferences_settings_repository.dart`

**Required:**
- Add a `GameMode` enum (`twoD`, `threeD`) in the domain layer (pure Dart, no Flutter import), or represent the mode as a stable persisted `String` (`"2D"` / `"3D"`) — pick one and justify. Prefer an enum with an explicit stable storage key so the ARB label and the persisted value stay decoupled.
- Add a `gameMode` field to `PlayerSettings` with a non-null default of **2D**. Thread it through the constructor, `PlayerSettings.defaults()` (must be 2D), and `copyWith`.
- Persist/read it in `SharedPreferencesSettingsRepository` under a new key (e.g. `settings.gameMode`), following the exact serialization pattern used for `languageCode`/`soundEnabled`. A missing/unknown stored value must fall back to 2D.

### B2 — Application: controller setter

**Files to audit:**
- `lib/features/settings/presentation/settings_screen_controller.dart` (see `setLanguage`, `_save`).

**Required:**
- Add `Future<void> setGameMode(GameMode mode)` that calls `_save(_settings.copyWith(gameMode: mode))` — identical shape to `setLanguage`. `_save` already does optimistic `notifyListeners()` + persist.

### B3 — App-level reactive state

**Files to audit:**
- `lib/core/app/app_settings_controller.dart` (`AppSettingsController`, currently holds `locale`).
- `lib/core/app/app_settings_scope.dart`
- `lib/core/app/app_bootstrap.dart` (seeds `AppSettingsController` from saved prefs).
- `lib/core/app/arrow_poc_app.dart` (wires the scope below `MaterialApp`).

**Required:**
- Add a reactive `gameMode` to `AppSettingsController` (default 2D) with a `setGameMode(...)` that `notifyListeners()` only on change — mirror `setLocale`.
- Seed it from saved `PlayerSettings.gameMode` in `app_bootstrap.dart` alongside the locale seed.
- In `_GameModeSelectorCard.onChanged` (Settings), after `controller.setGameMode(...)`, also call `AppSettingsScope.maybeOf(context)?.setGameMode(...)` — exactly as the language dropdown calls `setLocale`. This is what makes the menu update immediately.

### B4 — Settings UI

**Files to audit:**
- `lib/features/settings/presentation/settings_screen.dart` (`_SettingsContent`, `_LanguageSelectorCard`).
- `lib/features/game/presentation/game_ui_keys.dart` (add a key for the selector).

**Required:**
- Add a `_GameModeSelectorCard` next to `_LanguageSelectorCard` (a `Card` with a title from `localizations.gameMode` and a `SegmentedButton`/`DropdownButton` with two options: `localizations.gameMode2D` = "2D" and `localizations.gameMode3D` = "3D").
- Give the control a stable key (e.g. `GameUiKeys.gameModeSelector` or `const Key('settings-game-mode-selector')`).
- Reflect `controller.settings.gameMode` as the current value; `onChanged` calls the B3 flow.
- Optional helper text under the selector (`localizations.gameModeHint`, e.g. EN "Choose which level set the menu opens." / ES "Elige qué conjunto de niveles abre el menú.").

### B5 — Menu + filtering (presentation only)

**Files to audit:**
- `lib/features/home/presentation/home_screen.dart` (Levels + Leaderboard `_MenuNavButton`s).
- `lib/features/levels/presentation/level_selection_screen.dart` (`_loadScreenData`, list build).
- `lib/features/leaderboard/presentation/leaderboard_level_picker_screen.dart` (`_loadLevels`, list build).
- `lib/features/game/domain/level.dart` (`level.boardGraph`, `level.number`), `lib/features/game/domain/board_graph.dart` (`isMultiLayer`).

**Required:**
- Define a single presentation-layer predicate, e.g. `bool isThreeDLevel(Level l) => l.boardGraph.isMultiLayer || (l.number ?? 0) >= 21;`, in a shared presentation helper (do **not** put it in domain or application). 2D = `!isThreeDLevel`.
- The active mode reaches these screens via `AppSettingsScope.maybeOf(context)?.gameMode` (read reactively so a change re-filters without a manual reload). Do **not** re-read `PlayerSettings` in these screens.
- `LevelSelectionScreen`: filter the loaded `levels` list to the active mode before building cards. In 3D, show only levels 21–25; in 2D, only 1–20. Load/use-case/level-loader code is unchanged — filter the already-loaded list.
- `LeaderboardLevelPickerScreen`: same filter on its loaded list.
- Menu buttons: **Levels** and **Leaderboard** navigate to the same routes as today (`AppRoutes.levels`, `AppRoutes.leaderboardLevelPicker`); the destination screens filter themselves from the scope. (This is preferred over passing a route argument, so the pushed screen stays reactive if the mode changes while open — but passing an argument is acceptable if you justify it and still read the scope for reactivity.)
- ~~Progress stays separated: 2D uses `progress.*`, 3D uses `progress3d.*` (existing behavior — do not merge or change namespaces).~~ **[Correction — Phase 24.2: `progress3d.*` never existed. A single `progress.*` namespace stores all completions keyed by internal level number (1-25); per-mode unlock is computed from that shared set, not from separate namespaces.]**

---

## Task C — Localization

Add to **both** `app_en.arb` and `app_es.arb` (with `@`-metadata entries), then regenerate:

| Key | EN | ES |
| --- | --- | --- |
| `challenges` | Challenges | Retos |
| `gameMode` (existing — reused as selector title) | Game Mode | Modo de juego |
| `gameMode2D` | 2D | 2D |
| `gameMode3D` | 3D | 3D |
| `gameModeHint` (if used) | Choose which level set the menu opens. | Elige qué conjunto de niveles abre el menú. |

Regenerate the Dart localizations after editing ARBs:

```bash
flutter gen-l10n
```

Confirm `app_localizations.dart`, `app_localizations_en.dart`, `app_localizations_es.dart` now expose the new getters. Do not hand-edit the generated files.

---

## Constraints

1. Do not modify `backend-poc-arrow` or any backend code.
2. Do not modify auth, sync, leaderboard **API/fetch/submit** code, or any API contract.
3. Do not regenerate `assets/levels/manual_levels.json` or `manual_levels_3d.json`.
4. Domain layer stays pure Dart — no Flutter/HTTP/storage imports (the `GameMode` enum must have none).
5. Screens/controllers must not call `http.Client` or `SharedPreferences` directly — go through use cases / DI factories.
6. Graph-based runtime only — no grid/matrix/tile logic.
7. The 2D-vs-3D filter must live in **presentation**, not domain or application. Use cases and level loaders are untouched.
8. Default game mode is **2D**. Existing 2D behavior must remain byte-for-byte unchanged for a user who never opens the selector.
9. The "Challenges" button stays disabled (`onPressed: null`).
10. Never work on `main` — stay on `feat/phase-24-game-mode-selector`.
11. Never commit or push automatically — manual audit required.

---

## Test Coverage

- `PlayerSettings` / repository: persists and reads back `gameMode`; missing/unknown value defaults to 2D.
- `SettingsScreenController.setGameMode`: updates `settings.gameMode` and calls save.
- Settings widget test: selecting "3D" invokes the controller and the `AppSettingsScope` setter.
- `LevelSelectionScreen`: with a fake mixed level list (some `number >= 21` / `isMultiLayer`), 2D mode shows only 1–20 and 3D mode shows only 21–25.
- `LeaderboardLevelPickerScreen`: same filter assertion.
- Keep all existing tests green (including the Phase 23 leaderboard-picker and save-race tests).

---

## Validation

Run these after implementation. All must pass.

```bash
flutter gen-l10n          # regenerate localizations after ARB edits
flutter analyze           # 0 issues
flutter test              # all existing tests plus the new tests pass
```

`node tool/gen_levels.js --validate-only` is **not applicable** — no level files are touched. Do not run `--generate`.

---

## After Completion

1. Update `docs/CODEX_HANDOFF.md` using `harness/templates/handoff_update_template.md` (add a Phase 24 section: files touched, what changed per task, verification results, limitations).
2. Update `harness/context/phase_registry.md` — add Phase 24 and mark it COMPLETE.
3. Update `harness/metrics/improvement_log.md`.
4. Report:
   - Files changed / created.
   - `flutter analyze` result.
   - `flutter test` result (counts).
   - `node tool/gen_levels.js --validate-only` — state N/A (no level files touched).
   - Confirmation that `backend-poc-arrow` was **not** modified.
   - Confirmation that `manual_levels.json` / `manual_levels_3d.json` were **not** regenerated.
   - Any deviations from this phase prompt, with justification.
5. Await Technical Lead approval before any commit.

---

Do not be verbose. Be direct.
