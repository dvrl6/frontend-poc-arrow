# PHASE 12.1 — Head-Only Collision for Bent Arrows

Read before starting:
- `frontend-poc-arrow/docs/CODEX_HANDOFF.md`
- `frontend-poc-arrow/docs/LEVEL_AUTHORING.md` *(if levels are involved)*
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

Phase 12 fixed the sparse-graph blind spot by sweeping forward using
coordinate-based node lookup (`nodeByCoordinate`) instead of graph-edge
adjacency. That fix was correct in mechanism but **over-applied in scope**.

- **Current (wrong) behavior:** `MovementResolver` sweeps forward from *every*
  covered node of the moving arrow — start, intermediate body nodes, and head.
  Body nodes now run independent collision checks, so a bent arrow whose head
  path is clear is incorrectly reported as colliding because one of its body
  nodes has a blocker at the adjacent coordinate.
- **Correct rule:** an arrow is a **rigid piece** — the head leads, the body
  follows along the head's path. Only the **head** (`endNodeId`) collides
  against other arrows. Body nodes do not have independent collision detection;
  they simply occupy the path the head already traversed. If the head is
  blocked, the whole arrow rolls back atomically (P9 behavior unchanged).

This is a scope correction on top of P12, not a revert. The coordinate-based
stepping introduced in P12 stays — it is applied **only from the head**.

---

## Task

1. Audit the sweep / movement resolution path:
   - `lib/features/game/application/movement_resolver.dart`
   - `lib/features/game/domain/board_graph.dart` (`nodeByCoordinate`).
   - `lib/features/game/domain/arrow_path.dart` (`endNodeId`, `orderedNodeIds`).
2. In `MovementResolver`, sweep forward by coordinate **only from the head node
   (`endNodeId`)**. Remove the per-covered-node sweep loop so intermediate body
   nodes no longer run independent collision checks.
3. The head steps forward by coordinate (`direction.applyTo(coordinate)` →
   `nodeByCoordinate`). On encountering a blocker node or blocked edge →
   collision → atomic rollback (no partial movement). On reaching the board
   boundary → exit.
4. Keep `tool/gen_levels.js` `canExit` semantically aligned with the runtime so
   generated levels remain solvable under head-only physics. Regenerate levels
   only if validation shows existing fixtures are no longer solvable.
5. Add/extend tests:
   - A bent arrow whose **head path is clear** but a **body node sits adjacent
     to another arrow** must still **escape** (regression for the P12 over-check).
   - Preserve the P12 test where the **head** is blocked at an adjacent
     coordinate → collision.
   - `test/features/game/application/bent_arrow_test.dart`.

---

## Constraints

- Work **only** inside `frontend-poc-arrow/`.
- Do not modify `backend-poc-arrow` or any backend code.
- Do not modify auth, sync, leaderboard, or API code.
- Do not modify Git remotes.
- Graph-based runtime only — no grid/matrix/tile logic.
- Whole-arrow collision + atomic rollback must remain in `MovementResolver`,
  not in presentation.
- Work on branch `feat/phase-12-collision-fix` (already created).
- Do not commit or push. Stage only if ≥ 95% confident.

---

## Validation

Run these after implementation. All must pass.

```bash
flutter analyze
flutter test
node tool/gen_levels.js --validate-only   # only if level files were touched
```

Bent-arrow tests must demonstrate: (a) head blocked → collision + rollback;
(b) head clear, body node adjacent to another arrow → escape.

---

## After Completion

1. Update `docs/CODEX_HANDOFF.md` using `harness/templates/handoff_update_template.md`.
2. Update `harness/context/phase_registry.md`.
3. Update `harness/metrics/improvement_log.md`.

---

Do not be verbose. Be direct.
