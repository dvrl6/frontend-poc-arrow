---
name: improvement_log
type: metrics
---

# Improvement Log

Track what worked, what didn't, and what to adjust for the next session.

| Date | Session | What Worked | What Didn't | Token Efficiency | Adjustments for Next Time |
|------|---------|-------------|-------------|------------------|---------------------------|
| 2026-06-19 | Phase 12 Prep | Harness structure created cleanly in one pass; plan-mode audit caught doc path mismatch (`docs/` at wrong root) | — | Low (docs-only, no iteration) | Use `harness/context/current_constraints.md` as the first read in every future phase prompt |
| 2026-06-19 | Phase 12 | Coordinate-based sweep fixed the collision bug correctly; regression test pinpointed exact scenario; JS and Dart fixes were symmetric | Comb fallback density was wrong (bad parameter tables); test semantics label needed updating after regeneration; context summary hit limit mid-session | Medium (two context windows; summarized) | Fix fallback density parameters before running `--generate`; update hardcoded semantics labels whenever levels regenerate |
| 2026-06-19 | Phase 12.1 | Scope correction landed cleanly; pre-implementation audit identified all three affected tests before any code was written; single resolver line change + 3 test renames/updates; 109/109 green in one pass | — | High (one pass, no iteration) | When auditing, also grep `exit_attempt_resolver_test.dart` — it had an overlapping body-sweep test that also needed updating |

| 2026-06-19 | Phase 13 | Single method change in painter; pre-implementation audit was thorough enough to write correct stagger math on the first pass; 109/109 green without iteration | Straight-line-per-node translation kept bent shape intact; body nodes did not retrace the head's route | High (one pass, no iteration) | Per-segment stagger math should account for long arrows (>5 nodes); cap total stagger at 0.5 to avoid head vanishing before tail starts |
| 2026-06-19 | Phase 13 (rework) | Arc-length track sampling landed cleanly; pre-implementation audit of the exact buggy line (`pos + dir * totalDistance * localT`) made the fix unambiguous; 109/109 green on first compile | One naming collision (`headPos` defined twice) caught by analyzer — renamed trailing use to `displacedHead`; two-pass compile | High (two analyzer runs, no logic iteration) | When rewriting a method that ends with `final headPos = displaced[n-1]`, rename the trailing variable up front to avoid duplicate-definition errors |

| 2026-06-19 | Phase 13.1 | `canExit` head-only fix dramatically improved random-algorithm pass rate (from ~1/15 to 13/15 levels); mixed-lane fallback solved the remaining 2 hard levels cleanly; 109/109 green on first compile | Old comb fallback produced horizontal-only output — variety check failed for all fallback levels; first mixed-layout attempt had DISCONNECTED(5) because `weave()` is vertical-only and didn't bridge H-section gaps | Medium (3 code iterations: bias removal, canExit fix, weaveH fix) | When replacing the comb fallback, prototype the layout and check connected-components first before running full generation — the DISCONNECTED failure is a fast indicator of missing bridge edges |

| 2026-06-20 | Phase 13.1 refactor | Raising hard-tier retry budget from 200 → 3000 was sufficient; levels 14 & 15 found at attempts 209 and 208 — well within the new budget; `buildCombFallback` removed as a shipped-level source; 109/109 green; all 15 levels confirmed from random partition | — | High (one pass, no iteration) | For future generator tuning: the gap between 200-retry failure and ~210-attempt success shows the hard-variety success rate is ~0.5–1% per attempt — budget should be at least 10× the expected first-success attempt count |
| 2026-06-20 | Phase 13.2 (level rename) | Single-source rename in `LEVEL_DEFS`; generation algorithm untouched so all invariants held on regenerate | Initial pass only updated the JSON contract test; 3 UI/widget tests still hard-coded `'First Exit'`/`'Final Maze'` and failed — surfaced by running the suite, not the pre-edit audit | Medium (one extra test run to find the missed assertions) | When renaming a data value shown in the UI, grep ALL test files for the literal string before editing — not just the obvious contract test |

---

*Append a new row after each phase or significant session.*
