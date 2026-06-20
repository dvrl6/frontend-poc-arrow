---
name: phase_registry
type: context
---

# Phase Registry

| Phase | Date | Status | Files Touched (key) | Key Decisions |
|-------|------|--------|---------------------|---------------|
| P3 | — | Merged | `pubspec.yaml`, `lib/main.dart`, project scaffold | Flutter project bootstrapped; Clean Architecture folder structure established |
| P4 | — | Merged | `lib/features/game/domain/` | Graph-based domain: Arrow, Node, Edge, GameSession, MovementResolver; no matrix/grid |
| P5 | — | Merged | `assets/levels/manual_levels.json`, `lib/features/game/infrastructure/` | Manual JSON levels as authoritative source; LevelDefinitionValidator introduced |
| P6 | — | Merged | `lib/features/game/presentation/` | Playable UI: GraphBoard painter, tap-to-move, victory screen |
| P7 | — | Merged | `lib/features/progress/`, `lib/features/settings/`, audio assets | Local progress + unlocking (SharedPreferences); settings screen; audio foundation |
| P8 | — | Merged | `lib/core/network/`, `lib/features/auth/`, `lib/features/leaderboard/`, `lib/features/progress/infrastructure/` | HTTP integration; optional auth; progress sync with merge policy; leaderboard submission; backend non-blocking |
| P9 | — | Done | `lib/features/game/domain/`, `lib/features/game/application/`, `lib/features/game/presentation/`, `assets/levels/manual_levels.json` | Full-exit rule; whole-arrow collision; atomic rollback; lives system (3 lives/−1 per 2 mistakes/game-over at 6); exit + collision animations; level redesign (15 levels); 92 tests |
| P10 | — | Done | `docs/LEVEL_AUTHORING.md`, `tool/gen_levels.js`, `assets/levels/manual_levels.json`, `lib/features/game/presentation/widgets/graph_board.dart` | Level authoring guide; greedy solvability solver; density tuning; pan/zoom (`InteractiveViewer`); connected-traversal-graph requirement; 95 tests |
| P11 | — | Done | `lib/features/game/domain/arrow_path.dart`, `lib/features/game/domain/level_definition_validator.dart`, `lib/features/game/presentation/widgets/graph_board_painter.dart`, `lib/features/game/presentation/widgets/graph_board_hit_tester.dart` | `orderedNodeIds` added to ArrowPath; smooth polyline rendering with `StrokeJoin.round`; hit-test uses ordered nodes; 107 tests |
| P11b | — | Done | `tool/gen_levels.js`, `assets/levels/manual_levels.json`, `test/features/game/infrastructure/manual_levels_test.dart` | Random level generator rewrite (sparse graph + DFS partition); comb pattern for bent-arrow tiers; 108 tests |
| P12 Prep | 2026-06-19 | Done | `harness/` (12 new files) | Development harness created; no Dart code changed; baseline 108 tests unchanged |
| P12 | 2026-06-19 | Done | `lib/features/game/application/movement_resolver.dart`, `lib/features/game/domain/board_graph.dart`, `tool/gen_levels.js`, `assets/levels/manual_levels.json`, `test/features/game/application/bent_arrow_test.dart`, `test/features/game/presentation/playable_game_ui_test.dart` | Collision fix: sweep now steps by coordinate (not graph edge) so sparse-graph levels detect blockers at adjacent coords without a connecting edge; JS solver updated symmetrically; levels regenerated; comb fallback density parameters corrected; 109 tests |
| P12.1 | 2026-06-19 | Done | `lib/features/game/application/movement_resolver.dart`, `test/features/game/application/bent_arrow_test.dart` (+ `tool/gen_levels.js`, `assets/levels/manual_levels.json` if needed) | Scope correction on P12: only the HEAD (`endNodeId`) sweeps/collides; body nodes follow the head's path with no independent collision check. Arrow is a rigid piece — head leads, body follows; head blocked → whole-arrow atomic rollback |

## Notes

- "Date" column: fill in when the phase is executed.
- "Files Touched" lists key files only; see `docs/CODEX_HANDOFF.md` for the full list per phase.
- Update this table at the end of each phase using `harness/templates/handoff_update_template.md`.
