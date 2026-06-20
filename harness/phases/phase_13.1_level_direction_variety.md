# PHASE 13.2 — Level Name Simplification

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

---

## Context

Levels currently carry descriptive names ("First Exit", "L-Turn", "Comb Grid", etc.).
These names are surfaced in the UI and in tests. The goal is to simplify them to generic
numeric labels ("Level 1" … "Level 15") across all three difficulty tiers.

The level 2 name is pinned in `test/features/game/infrastructure/manual_levels_test.dart`
and must be updated alongside the generator.

---

## Task

1. In `tool/gen_levels.js`, update every entry in `LEVEL_DEFS` so that `name` is
   `'Level N'` where `N` is the level number. No other field changes.
2. In `test/features/game/infrastructure/manual_levels_test.dart`, update the assertion
   on line 132 from `'L-Turn'` to `'Level 2'`.
3. Regenerate `assets/levels/manual_levels.json`:
   ```
   node tool/gen_levels.js --generate
   ```
4. Do **not** touch collision logic, movement rules, the game engine domain
   (`MovementResolver`, `BoardGraph`, `ArrowPath`), or arrow rendering/animation code.

---

## Constraints

- Work only inside `frontend-poc-arrow/`.
- Do not modify `backend-poc-arrow` or any backend code.
- Do not modify auth, sync, leaderboard, or API code.
- Do not modify Git remotes.
- Do not commit or push. Stage only if ≥ 95% confident.
- Work on branch `feat/phase-13-exit-animation` (already exists).

---

## Validation

Run these after implementation. All must pass.

```bash
flutter analyze
flutter test
node tool/gen_levels.js --validate-only
```

---

## After Completion

1. Update `docs/CODEX_HANDOFF.md` using `harness/templates/handoff_update_template.md`.
2. Update `harness/context/phase_registry.md` — mark Phase 13 and Phase 13.1 as Complete.
3. Update `harness/metrics/improvement_log.md`.

---

Do not be verbose. Be direct.
