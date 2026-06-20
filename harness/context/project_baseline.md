---
name: project_baseline
type: context
---

# Project Baseline

## Tech Stack

- **Framework**: Flutter (Dart)
- **Architecture**: Clean Architecture — Domain → Application → Infrastructure → Presentation
- **Storage**: local-first (SharedPreferences for progress + token); optional backend via HTTP
- **Level source**: `assets/levels/manual_levels.json` (authoritative, hand-editable)
- **Level tool**: `tool/gen_levels.js` (Node.js; validates + optionally regenerates)

## Immutable Core Rules

These rules define the game model and must not be changed without an explicit architectural decision:

| Rule | Detail |
|------|--------|
| Graph-based | No matrix/grid/tile runtime model. Nodes + edges only. |
| Arrows = arbitrary paths | Shape is defined by `occupiedEdges`; no fixed templates (L/U/zigzag are just path descriptions). |
| Whole-arrow collision | Collision sweeps every node in the arrow's full occupied shape, not just the head. |
| Atomic exit/rollback | An exit attempt either fully escapes or leaves the arrow exactly as it was. No partial movement. |
| Lives system | 3 lives. −1 life per 2 mistakes. Game-over at 6 mistakes (0 lives). |
| Score formula | `max(0, 1000 − (mistakeCount × 100) − (movesCount × 5))`. No timer. |
| Backend optional | All backend calls are best-effort and non-blocking. Local gameplay must work without a backend. |
| `manual_levels.json` authoritative | The JSON is the source of truth. Do not overwrite without `--generate`. |

## Architecture Layers

```
Domain          → pure Dart; entities, value objects, repository interfaces
Application     → use cases; orchestrates domain; no UI
Infrastructure  → adapters (HTTP, SharedPreferences, JSON parsing)
Presentation    → widgets, controllers, painters; imports Application only
```

## Completed Phases

| Phase | Title | Status |
|-------|-------|--------|
| P3 | Flutter Bootstrap | Merged |
| P4 | Graph-Based Game Engine Domain | Merged |
| P5 | Manual Graph-Based Levels | Merged |
| P6 | Playable Game UI with Local Manual Levels | Merged |
| P7 | Local Progress, Level Unlocking, Settings, Audio, UX Polish | Merged |
| P8 | Frontend–Backend Integration | Merged |
| P9 | Gameplay Rules Fixes, Lives System, Level Redesign, Stability | Done |
| P10 | Level Authoring, Density Tuning, Board UX Polish (pan/zoom) | Done |
| P11 | Varied Arrow Shape Rendering (smooth polyline, orderedNodeIds) | Done |
| P11b | Random Level Generator Rewrite + Bent Arrow Regeneration | Done |

## Test Baseline (P11b)

- `flutter analyze`: 0 issues
- `flutter test`: 108 tests passing
- `node tool/gen_levels.js --validate-only`: all 15 levels valid, comp=1, free=−, solvable=true

## Active Known Issues

- Collision bugs in bent arrows — **P12 pending**
- Manual emulator validation for P9–P11 still pending (listed in handoff)
- Dense hard levels may require pinch-zoom/drag on small screens
- Token storage uses SharedPreferences (academic/demo scope; secure storage is future work)
