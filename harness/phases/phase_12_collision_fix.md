# PHASE 12 — Collision Fix for Bent Arrows

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

P11 added varied arrow shape rendering. Polyline rendering works and bent
arrows display correctly via `orderedNodeIds` on `ArrowPath`. However,
collision detection is broken for bent (multi-segment) arrows.

- **Observable bug:** bent arrows escape when they should collide with other
  arrows. The whole-arrow collision / atomic rollback established in P9 does
  not trigger for arrows whose path bends through intermediate nodes.
- **Suspected root cause:** the sweep logic resolves occupancy using graph
  edge adjacency instead of coordinate-based node lookup. Intermediate nodes
  along a bent arrow's polyline are never checked against blockers occupying
  those coordinates, so the arrow sweeps past them.

---

## Task

Fix collision detection so every node a bent arrow traverses — start,
intermediate, and exit nodes — is checked against blockers.

1. Audit the sweep / movement resolution path:
   - `lib/features/game/domain/movement_resolver.dart`
   - The board/graph adjacency lookup used during sweep (e.g. `board_graph.dart`).
   - `lib/features/game/domain/arrow_path.dart` (`orderedNodeIds`).
2. Replace graph-edge-adjacency occupancy checks with coordinate-based node
   lookup so intermediate nodes on the polyline are evaluated for collision.
3. Ensure the whole-arrow collision + atomic rollback behavior from P9 applies
   identically to straight and bent arrows.
4. Add/extend tests proving bent arrows collide with a blocker on an
   intermediate node (e.g. `test/features/game/domain/bent_arrow_test.dart`).
5. If level fixtures are needed to reproduce, regenerate via the existing tool
   rather than hand-editing matrices.

---

## Constraints

- Work **only** inside `frontend-poc-arrow/`.
- Do not modify `backend-poc-arrow` or any backend code.
- Do not modify auth, sync, leaderboard, or API code.
- Do not modify Git remotes.
- Graph-based runtime only — no grid/matrix/tile logic.
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

Bent-arrow collision tests must pass and demonstrate that an arrow blocked at
an intermediate node rolls back atomically.

---

## After Completion

1. Update `docs/CODEX_HANDOFF.md` using `harness/templates/handoff_update_template.md`.
2. Update `harness/context/phase_registry.md`.
3. Update `harness/metrics/improvement_log.md`.

---

Do not be verbose. Be direct.
