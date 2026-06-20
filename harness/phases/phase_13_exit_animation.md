# PHASE 13 — Exit Animation Duration Tuning

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

The path-following exit animation (train on tracks) is implemented and working
correctly. Body nodes retrace the head's route — bent arrows (L, U, zigzag)
round their own corner on the way out — with correct staggered timing and a
head-leading fade. This is settled and must not be touched.

**The problem is purely duration.** The exit currently runs in ~360 ms, which is
too short: the path traversal flashes by instead of reading as a visible slide.
The train effect is hard to perceive.

**Goal:** lengthen the animation to ~600–800 ms so the arrow visibly slides
along its path. Nothing about the path-following or stagger *logic* changes —
only how long the controller runs.

The duration lives in `graph_board.dart`:

```dart
_exitController =
    AnimationController(vsync: this, duration: const Duration(milliseconds: 360))
```

The painter (`_drawExitingArrow`) is driven entirely by the scalar
`exitProgress` (0..1) and computes stagger/track sampling proportionally, so a
longer controller duration stretches the existing effect without any painter
math change.

---

## Task

1. In `lib/features/game/presentation/widgets/graph_board.dart`, increase the
   `_exitController` duration from `360 ms` to a value in the **600–800 ms**
   range so the slide is clearly visible.
2. Confirm the staggered timing remains proportional (it already is — stagger is
   computed as fractions of `exitProgress` in the painter, so it scales with the
   longer window automatically). Do **not** alter `perSegmentDelay`, the stagger
   cap, or the arc-length sampling.
3. Verify the arrow still fully clears the board and is faded out by
   `exitProgress == 1` at the new duration.

---

## Constraints

- Work **only** inside `frontend-poc-arrow/`.
- Do not modify `backend-poc-arrow` or any backend code.
- Do not modify auth, sync, leaderboard, or API code.
- Do not modify Git remotes.
- **Do not change the path-following or stagger logic in `_drawExitingArrow` —
  ONLY the controller duration.**
- Do not change collision logic, movement rules, or the game engine domain.
- Leave the collision animation (shake + flash, `_shakeController`, 300 ms)
  unchanged.
- Work on branch `feat/phase-13-exit-animation` (already exists).
- Do not commit or push. Stage only if ≥ 95% confident.

---

## Validation

Run these after implementation. All must pass.

```bash
flutter analyze
flutter test
```

Manual check: trigger an exit on a **bent (L/U/zigzag)** arrow and confirm the
slide along the path is now clearly visible, the head still leads, the shape
stays rigid, and the arrow is fully off-board and faded by the end.

---

## After Completion

1. Update `docs/CODEX_HANDOFF.md` using `harness/templates/handoff_update_template.md`.
2. Update `harness/context/phase_registry.md` (keep Phase 13 as **PENDING (refactoring)**).
3. Update `harness/metrics/improvement_log.md`.

---

Do not be verbose. Be direct.
