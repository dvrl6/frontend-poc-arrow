---
name: current_constraints
type: context
---

# Current Constraints

Check every item on this list before starting any phase. Update this file when constraints change (add a note explaining what changed and why).

---

## Backend

- **Do not modify `backend-poc-arrow` or any backend code.** The frontend is the only scope.
- **Do not modify Git remotes.** Remote URLs are fixed.
- Backend integration is **additive only**. Existing local gameplay must never depend on the backend being available.

## Frontend Code

- **Do not modify auth, sync, leaderboard, or API code** unless the task explicitly requires it.
- Screens and controllers must not call `http.Client` static helpers or `SharedPreferences` directly — use infrastructure adapters only.
- Domain layer must remain pure Dart (no Flutter, HTTP, or storage imports).

## Levels

- `assets/levels/manual_levels.json` is the **authoritative hand-editable source**. Do not run `node tool/gen_levels.js --generate` unless regeneration is explicitly intended by the task.
- `--validate-only` is always safe and reads without writing.
- **Level 2 test contract**: name='L-Turn', arrow count=11. Do not change level 2's name or arrow count without updating `test/features/game/infrastructure/manual_levels_test.dart`.

## Git

- Never work on `main`.
- Never commit or push automatically. Manual audit is required before every commit.
- Never force-push.

## Gameplay Model

- No matrix/grid/tile runtime model may be introduced.
- Arrow shapes are arbitrary paths (defined by `occupiedEdges`). No fixed templates.
- Whole-arrow collision must remain in the resolver (`MovementResolver`), not in presentation.

---

*Last updated: 2026-06-19 (Phase 12 — coordinate-based sweep fix; levels regenerated)*
