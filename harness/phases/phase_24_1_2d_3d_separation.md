# PHASE 24.1 — 2D/3D Level File Separation (Option 2: File Split, Global Numbering Preserved)

Read before starting:
- `frontend-poc-arrow/docs/CODEX_HANDOFF.md`
- `frontend-poc-arrow/docs/LEVEL_AUTHORING.md`
- `frontend-poc-arrow/harness/context/current_constraints.md`

---

## Mandatory Pre-Implementation

Before writing any code:

1. Audit all files relevant to this task (list below).
2. Explain your understanding of the current state.
3. State your confidence level. Must be ≥ 95% to proceed. If lower, ask clarifying questions.
4. **Wait for explicit approval before writing any code.**

---

## Context (audited — do not re-litigate)

This phase was chosen as **Option 2** of the Phase 24.1 audit: split the single authoring file
into two files **while keeping internal level numbers globally unique**. 2D levels stay **1–20**,
3D levels stay **21–25**. There is NO internal renumber. The presentation-layer display offset
(3D shows as 1–5 via `internal - 20`) stays exactly as-is.

Why this scope (and not the full renumber): the internal `number` (1–25) is the primary key at
three layers — local progress storage (`progress.*`, keyed by raw int), the backend
`Level.number @unique`, and the frontend `number → backendId` map. Renumbering 3D to 1–5 would
collapse that key and require a backend schema migration and a risky progress migration. Keeping
numbers globally unique avoids all of that: **progress, leaderboard, sync, and backend are
untouched.** The only real change is *where the level JSON is authored/loaded from* and the
tooling/tests around it.

### Current state (verified facts)

- **Single asset**: `assets/levels/manual_levels.json`, path constant in
  `lib/features/game/infrastructure/local_level_data_source.dart:10`
  (`LocalLevelDataSource.manualLevelsAssetPath`). Registered once in `pubspec.yaml:64`.
  Loaded once into a single 25-level list.
- **DTO**: `ManualLevelCollectionDto.fromJsonString` (in `manual_level_dto.dart`) parses a
  `{ "levels": [...] }` object. Reusable as-is for both files.
- **Repository**: `AssetLevelRepository.getManualLevels()` maps → validates → returns the list.
  It holds a single `LocalLevelDataSource`.
- **DI**: `LocalLevelDependencies.createRepository()` constructs the `LocalLevelDataSource` with
  `RootBundleAssetTextLoader`.
- **Numbering / offset**: `lib/features/game/presentation/level_mode_filter.dart` —
  `twoDLevelCount = 20`, `displayNumberFor(internal, mode) => threeD ? internal-20 : internal`,
  `isThreeDLevel` prefers `boardGraph.isMultiLayer` and falls back to `number > 20`.
  **This file must NOT change.**
- **id mapping**: `manual-${number.padLeft(3,'0')}` in `level_definition_mapper.dart:15`.
  Because numbers stay globally unique, ids stay unique (`manual-001`…`manual-025`). No change.
- **Tooling** (`tool/gen_levels.js`): single `ASSET` path. Modes today: `--generate` (1–15),
  `--generate-figures` (16–20), `--generate-3d` (21–25), `--validate-only`. `--validate-only`
  enforces contiguous `1..N`. `validateAll` hardcodes 1–5 easy / 6–10 medium / ≥11 hard and a
  strictly-increasing tier-average check.
- **Tests** (`test/features/game/infrastructure/manual_levels_test.dart`): hardcodes
  `hasLength(25)`, `first.number==1`, `last.number==25`, ids `manual-001/020/025`, tier bands,
  and reads `LocalLevelDataSource.manualLevelsAssetPath`.
- **Backend** (`backend-poc-arrow`): keyed by unique `number`. Since numbers do not change,
  **backend is untouched and its seed file remains a duplicate copy** — do not modify it.

---

## Task

Numbers stay globally unique: 2D = 1–20, 3D = 21–25. No renumber. No offset change.

### Task A — Split the asset into two files

1. Create `assets/levels/manual_levels_2d.json` containing levels **1–20** (nodes/edges/arrows
   byte-for-byte from the current `manual_levels.json`; same `{ "levels": [...] }` envelope).
2. Create `assets/levels/manual_levels_3d.json` containing levels **21–25** as-is (numbers stay
   21–25; same envelope).
3. Prefer generating these via the updated `gen_levels.js` (Task B) rather than hand-splitting,
   so the JSON matches the generator's output formatting exactly. Verify the union equals the
   old file's 25 levels.
4. **Delete** the old `assets/levels/manual_levels.json` **only after** loading + validation +
   tests are green against the two new files. (If you prefer, keep it until the end of the phase
   and remove in the final step.)

### Task B — Update `tool/gen_levels.js`

- Replace the single `ASSET` constant with `ASSET_2D`
  (`assets/levels/manual_levels_2d.json`) and `ASSET_3D` (`assets/levels/manual_levels_3d.json`).
- CLI modes:
  - `--generate-2d`: builds levels 1–15 (random) + 16–20 (figures), validates as the **2D set**,
    writes `manual_levels_2d.json`. (This is today's `--generate` + `--generate-figures` combined
    for the 2D file. Preserve the existing generation logic and seeds so output is stable.)
  - `--generate-3d`: builds levels 21–25 (the existing hand-designed `build3DLevel21..25`,
    numbers unchanged), validates as the **3D set**, writes `manual_levels_3d.json`.
  - `--generate`: shorthand that runs both `--generate-2d` and `--generate-3d`.
  - `--validate-only` (default): reads BOTH files and validates each **independently**.
- Split `validateAll` so the invariant set depends on which file is being validated:
  - **2D set** (1–20): keep the existing checks — tier progression (1–5 easy / 6–10 medium /
    11–20 hard), strictly-increasing tier averages, density bands, figure-level real-gap check,
    contiguous `1..20`.
  - **3D set** (21–25): assert all-`hard`, multi-layer (>1 distinct z), greedy-solvable,
    no single-node arrows (every arrow ≥ 2 nodes / ≥ 1 edge), and `hasRealInteriorGapExit3D`.
    Do NOT apply the easy/medium/increasing-average progression to the 3D file. Numbers must be
    contiguous `21..25`.
- Keep the deterministic seeds and generation algorithms intact — do not perturb existing level
  geometry. The goal is a file split, not regeneration of different levels.
- `--generate` / `--generate-2d` / `--generate-3d` must refuse to write if validation fails
  (preserve the existing "NOT WRITTEN — fix issues first" behavior per file).

### Task C — Update asset loading (Flutter)

- `pubspec.yaml`: register both `assets/levels/manual_levels_2d.json` and
  `assets/levels/manual_levels_3d.json` (remove the old single entry once the old file is deleted).
- `LocalLevelDataSource`: load BOTH JSONs and concatenate into one list, preserving order
  (2D 1–20 then 3D 21–25). Suggested approach: give it two asset paths
  (`manualLevels2dAssetPath`, `manualLevels3dAssetPath`), load each via the `AssetTextLoader`,
  parse each with `ManualLevelCollectionDto.fromJsonString`, and return the concatenation.
  Keep constructor injectable for tests (allow overriding both paths).
- `AssetLevelRepository`: no interface change needed if `LocalLevelDataSource` still exposes a
  single `loadManualLevels()` returning the merged list. Keep the map→validate→list pipeline.
- `LocalLevelDependencies.createRepository()`: construct the data source with both real asset
  paths (defaults). No other DI wiring changes.
- Internal numbers remain globally unique (1–20 / 21–25); ids remain `manual-001`…`manual-025`.
- **Do NOT change** `level_mode_filter.dart`, the display offset, `level_definition_mapper.dart`
  id logic, or any progress/leaderboard/sync code.

### Task D — Update tests

- `test/features/game/infrastructure/manual_levels_test.dart`: restructure into a **shared
  helper** plus **two top-level `group`s** (2D and 3D). Alternatively split into
  `manual_levels_2d_test.dart` and `manual_levels_3d_test.dart` sharing a helper file — either is
  acceptable; prefer the two-group single-file form to minimize churn.
  - The full merged repository still loads all 25 — keep an integration-style assertion that the
    combined list has 25 unique numbers / unique ids (`manual-001`, `manual-020`, `manual-025`).
  - **2D group** (levels 1–20): tier progression (easy/medium/hard by number), density bands,
    figure-level (16–20) real-gap check, bent-arrow-per-tier, no-free-nodes, solvable,
    single connected component, arrowhead orientation.
  - **3D group** (levels 21–25): all-`hard`, multi-layer (`boardGraph.isMultiLayer`),
    spanning/vertical arrows present, no single-node arrows, real-gap-3D semantics, solvable.
  - Update any assertions that read the old single asset path
    (`LocalLevelDataSource.manualLevelsAssetPath`) to read the two new paths.
- Do NOT change `game_screen_display_number_test.dart` — the display offset is unchanged, so
  internal 21 still displays as "1". It must keep passing.
- Add/adjust a small tooling-adjacent assertion only if one already exists; otherwise leave
  `gen_levels.js` behavior verified by the CLI validation step below.

### Task E — Documentation

- `docs/LEVEL_AUTHORING.md`: document the dual-file workflow — which file holds which levels
  (2D 1–20, 3D 21–25), the `--generate-2d` / `--generate-3d` / `--generate` / `--validate-only`
  commands, and that numbers stay globally unique (no renumber; the 1–5 display for 3D is a
  presentation offset only).
- `docs/CODEX_HANDOFF.md`: record Phase 24.1 state (files split, numbering preserved, backend
  untouched) using `harness/templates/handoff_update_template.md`.
- `harness/context/phase_registry.md`: add the Phase 24.1 entry.
- `harness/metrics/improvement_log.md`: add the Phase 24.1 line.

---

## Constraints

- Do not modify `backend-poc-arrow` or any backend code. Its seed remains a duplicate copy;
  because numbers are unchanged, no backend change is needed. **Confirm untouched.**
- Do not change internal level numbers. 2D stays 1–20, 3D stays 21–25.
- Do not touch progress, leaderboard, or sync logic (`features/progress/**`,
  `features/leaderboard/**`).
- Do not remove or alter the presentation display offset in `level_mode_filter.dart`.
- Do not perturb existing level geometry — this is a file split, not a regeneration of different
  levels. Regenerated output must be equivalent to the current 25 levels.
- Do not modify Git remotes.
- Do not commit or push automatically.

---

## Validation

Run these after implementation. All must pass.

```bash
# Generator: regenerate both files and validate both independently
node tool/gen_levels.js --generate-2d      # writes manual_levels_2d.json
node tool/gen_levels.js --generate-3d      # writes manual_levels_3d.json
node tool/gen_levels.js --generate         # shorthand: both
node tool/gen_levels.js --validate-only    # ALL VALID for BOTH files

# Flutter
flutter analyze                            # 0 issues
flutter test                               # all passing
```

Also verify manually:
- The union of the two files is exactly the previous 25 levels (numbers 1–25, contiguous,
  unique ids `manual-001`…`manual-025`).
- Old `assets/levels/manual_levels.json` is removed and no longer referenced anywhere
  (`grep -r manual_levels.json` returns only the two new files and generated build artifacts).
- App loads and plays a 2D level and a 3D level; 3D still displays as 1–5 in the app bar.
- Backend directory shows no diff.

---

## After Completion

1. Update `docs/CODEX_HANDOFF.md` using `harness/templates/handoff_update_template.md`.
2. Update `harness/context/phase_registry.md`.
3. Update `harness/metrics/improvement_log.md`.

---

Do not be verbose. Be direct.
