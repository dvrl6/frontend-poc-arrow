# Development Harness

Standardized workflow for all frontend-poc-arrow phases. Replaces the ad-hoc convention of reading `CODEX_HANDOFF.md` and remembering rules by memory.

## Purpose

- Capture the project baseline and active constraints in one place.
- Provide a reusable phase prompt template with a mandatory pre-approval checkpoint.
- Enforce validation gates before any commit.
- Track what worked and what didn't across sessions.

## How to Use This for a New Phase

1. Copy `templates/phase_prompt_template.md` into your phase prompt.
2. Fill in the `## Task` section with the specific deliverables.
3. Add any phase-specific constraints under `## Constraints`.
4. Follow `checklists/pre_implementation.md` before writing any code.
5. Follow `checklists/post_implementation.md` before calling the phase done.
6. Follow `checklists/pre_commit.md` before every commit.

## Directory Map

```
harness/
├── README.md                        ← you are here
├── context/
│   ├── project_baseline.md          ← tech stack, immutable rules, test baseline
│   ├── phase_registry.md            ← table of all phases (P3–present)
│   └── current_constraints.md       ← active constraints; update when they change
├── rules/
│   ├── git_workflow.md              ← branch naming, commit format, no-auto-commit
│   ├── architecture_boundary.md     ← layer rules, what can/cannot cross boundaries
│   └── validation_protocol.md       ← pre/during/post/pre-commit gates
├── templates/
│   ├── phase_prompt_template.md     ← starting point for every new phase prompt
│   └── handoff_update_template.md   ← structure for updating CODEX_HANDOFF.md
├── checklists/
│   ├── pre_implementation.md        ← gate before writing code
│   ├── post_implementation.md       ← gate before calling a phase done
│   └── pre_commit.md               ← gate before every commit
└── metrics/
    └── improvement_log.md           ← per-session notes on what worked/didn't
```

## How to Update Constraints

Edit `context/current_constraints.md` directly. Add a note at the bottom explaining what changed and why. Constraints must stay in sync with the handoff — if you add a constraint here, mention it in `docs/CODEX_HANDOFF.md` as well.

## How to Update the Phase Registry

Add a row to `context/phase_registry.md` after each completed phase. Use the handoff template to write the CODEX_HANDOFF entry first, then summarize it into the registry table.

## How to Update the Improvement Log

Append a row to `metrics/improvement_log.md` at the end of each session. Be honest about what slowed things down — the goal is to make the next session faster.
