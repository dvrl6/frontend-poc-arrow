---
name: git_workflow
type: rules
---

# Git Workflow

## Branch Naming

```
feat/<short-description>      new feature
fix/<short-description>       bug fix
refactor/<short-description>  refactor with no behavior change
docs/<short-description>      documentation only
```

Example: `fix/bent-arrow-collision`, `feat/game-timer`

## Rules

- **Never work on `main`**. Always work on a dedicated branch.
- **Never modify Git remotes.**
- **Never force-push.**

## Commit Message Format

```
<type>(<scope>): <short description>
```

Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`  
Scope: the feature or module affected (e.g. `collision`, `levels`, `harness`)

Examples:
```
fix(collision): correct full-shape sweep for bent arrows
feat(levels): add density tuning for hard tier
docs(harness): create development harness structure
```

## Commit Discipline

- **NO automatic commits.** Every commit requires a manual `git status` review.
- **NO automatic push or merge.**
- Only stage the files intended for this change — never `git add .` blindly.
- Review `git diff --staged` before committing.
- No secrets, `.env` files, or build artifacts in commits.

## PR Structure

When creating a pull request, include:

```
## Summary
- What changed and why

## Verification
- flutter analyze: [result]
- flutter test: [N tests passed]
- node tool/gen_levels.js --validate-only: [result if applicable]

## Manual Validation
- [list of manual checks performed, or "pending"]

## Notes
- [limitations, follow-up work, known issues]
```
