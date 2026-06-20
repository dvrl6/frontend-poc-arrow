---
name: architecture_boundary
type: rules
---

# Architecture Boundaries

## Layer Definitions

### Domain
- Pure Dart — no Flutter, no HTTP, no storage.
- Contains: entities (`Arrow`, `Node`, `Edge`, `GameSession`), value objects, repository interfaces, use-case interfaces.
- Key path: `lib/features/*/domain/`

### Application
- Use cases that orchestrate domain objects.
- No UI, no HTTP, no SharedPreferences.
- May import Domain only.
- Key path: `lib/features/*/application/`

### Infrastructure
- Adapters for external concerns: HTTP, SharedPreferences, JSON parsing, file I/O.
- May import Domain and Application interfaces.
- Key paths: `lib/features/*/infrastructure/`, `lib/core/network/`

### Presentation
- Flutter widgets, painters, controllers, screens.
- May import Application (use cases) only — not Infrastructure directly.
- Key path: `lib/features/*/presentation/`

## Dependency Rules

```
Domain      ← Application ← Infrastructure
                          ← Presentation ← (imports Application use cases)
```

- Domain must not import any other layer.
- Presentation must not import Infrastructure directly.
- Screens/controllers must not call `http.Client` or `SharedPreferences` directly.

## Backend Boundary

- The backend (`backend-poc-arrow`) is a separate project.
- The frontend only consumes the API through `lib/core/network/` and infrastructure repositories.
- All HTTP calls live in `lib/core/network/` (`ApiClient`, `HttpApiClient`) or infrastructure adapters.
- Backend calls are best-effort and non-blocking — failures must not break local gameplay.

## What Must Stay in Domain / Application

- `MovementResolver` (collision + escape logic) — must live in Application or Domain, never Presentation.
- `GameSession`, `MoveArrowUseCase`, `GameSessionService` — Application layer.
- Lives/score/mistake logic — Domain entities or Application use cases.

## What Must Stay in Presentation

- Animations, painters, hit-testing, UI state controllers.
- `GraphBoard`, `GraphBoardPainter`, `GraphBoardHitTester`, `GameScreenController`.
