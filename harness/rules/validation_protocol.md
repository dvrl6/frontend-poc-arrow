---
name: validation_protocol
type: rules
---

# Validation Protocol

## Pre-Implementation Gate

Before writing any code:

1. Read `docs/CODEX_HANDOFF.md`.
2. Read `docs/LEVEL_AUTHORING.md` (if levels are involved).
3. Read `harness/context/current_constraints.md`.
4. Identify and audit all files relevant to the task.
5. Write out your understanding of the current state.
6. State confidence ≥ 95%. If lower, ask clarifying questions before proceeding.
7. **Wait for explicit approval before writing any code.**

## During Implementation

- Run `flutter analyze` after any significant change to Dart files.
- Run the tests for affected files immediately after changing them — don't batch.
- If a test fails, fix it before continuing. Do not accumulate failing tests.

## Post-Implementation Gate

All of the following must pass before the phase is considered done:

```bash
flutter analyze           # must report 0 issues
flutter test              # all tests must pass; report the count
node tool/gen_levels.js --validate-only   # if any level files were touched
```

Additionally:
- Update `docs/CODEX_HANDOFF.md` with the phase summary.
- Update `harness/context/phase_registry.md` with the new phase entry.
- Update `harness/metrics/improvement_log.md`.

## Pre-Commit Gate

Before every commit:

1. Run `git status` and review every changed file.
2. Confirm only the intended files are staged.
3. Confirm no secrets, `.env` files, or build artifacts are staged.
4. Confirm commit message follows the convention.
5. **Do not commit automatically. Obtain explicit approval.**

## Level Validation

After editing `assets/levels/manual_levels.json`:

```bash
node tool/gen_levels.js --validate-only   # never writes; exits non-zero on failure
flutter test                               # Dart-side guarantees
```

The validator checks: structure, orthogonal edges, no-free-nodes, greedy solvability, density bands, strictly increasing tier averages, comp=1, hard-not-all-rectangular.
