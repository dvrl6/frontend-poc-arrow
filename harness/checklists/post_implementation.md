---
name: post_implementation_checklist
type: checklists
---

# Post-Implementation Checklist

Complete every item before calling a phase done.

## Validation Commands

- [ ] `flutter analyze` — reported 0 issues
- [ ] `flutter test` — all tests passed; count: ___
- [ ] `node tool/gen_levels.js --validate-only` — passed *(or: not applicable — no level files touched)*

## Documentation

- [ ] `docs/CODEX_HANDOFF.md` updated with phase summary (use `harness/templates/handoff_update_template.md`)
- [ ] `harness/context/phase_registry.md` updated with this phase entry
- [ ] `harness/metrics/improvement_log.md` updated

## Constraint Check

- [ ] No backend code was modified
- [ ] No Git remotes were modified
- [ ] Auth/sync/leaderboard/API code was untouched (unless this phase explicitly required changes)
- [ ] Architecture boundaries respected (no Presentation→Infrastructure direct imports)

---

*Do not mark the phase done until all boxes are checked.*
