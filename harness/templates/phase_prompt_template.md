# PHASE [N] — [Title]

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

## Task

[Specific actionable items. Be concrete. List files to create or modify.]

---

## Constraints

- Do not modify `backend-poc-arrow` or any backend code.
- Do not modify auth, sync, leaderboard, or API code unless this task explicitly requires it.
- Do not modify Git remotes.
- Do not commit or push automatically.
- [Add any phase-specific constraints here.]

---

## Validation

Run these after implementation. All must pass.

```bash
flutter analyze
flutter test
node tool/gen_levels.js --validate-only   # only if level files were touched
```

---

## After Completion

1. Update `docs/CODEX_HANDOFF.md` using `harness/templates/handoff_update_template.md`.
2. Update `harness/context/phase_registry.md`.
3. Update `harness/metrics/improvement_log.md`.

---

Do not be verbose. Be direct.
