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

---

*Append a new row after each phase or significant session.*
