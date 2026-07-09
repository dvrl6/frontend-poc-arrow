# PHASE 20 — Main Menu Redesign & Game Rebrand

Read before starting:
- `frontend-poc-arrow/docs/CODEX_HANDOFF.md`
- `frontend-poc-arrow/harness/context/current_constraints.md`

---

## Mandatory Pre-Implementation

Before writing any code:

1. Audit all files relevant to this task.
2. Explain your understanding of the current state.
3. State your confidence level. Must be ≥ 95% to proceed. If lower, ask clarifying questions.
4. **Wait for explicit approval before writing any code.**

---

## Context

Phases 3–19 are complete and merged to `main`. The game is feature-complete:
20 levels (1–15 random-partition boards, 16–20 figure silhouettes), gameplay,
collision resolution, audio, neon rendering, level selection, settings, auth,
sync, and leaderboard are all finished and polished.

Baseline: **122 tests passing**, `flutter analyze` clean.

**The only remaining prototype-grade surface is the main menu / landing screen.**
It lives at `lib/features/home/presentation/home_screen.dart` (not
`main_menu_screen.dart` — the task brief's path is illustrative). It currently
renders, top to bottom:

- The `appTitle` localized string ("Arrow POC") as `displaySmall`.
- The `homeSubtitle` string as plain `bodyMedium`.
- A `Card` showing `backendUrlLabel` + `AppConfig.apiBaseUrl` in `neonMint`.
- A `FilledButton` "Play" → `AppRoutes.levels`.
- An `OutlinedButton` "Settings" → `AppRoutes.settings`.

The screen is a plain `Column` inside a `SafeArea`/`Padding`, with no visual
identity. The in-game neon palette lives in `lib/core/theme/app_theme.dart`
(`neonMint 0xFF7AFDD6`, `neonBlue 0xFF1FC8FF`, `neonGreen 0xFF39FF8E`,
`neonYellow 0xFFF6FF3D`, `neonPink 0xFFFF36C2`, `neonPurple 0xFFB347FF`).

The Android app label is `frontend_poc_arrow` in
`android/app/src/main/AndroidManifest.xml`. Localized strings live in
`lib/core/localization/l10n/app_en.arb` and `app_es.arb`.

**Stay on branch `feat/phase-20-main-menu-redesign`** (already created and
checked out from latest `main`). Do **not** switch branches.

---

## Task

### 1 — Invent and apply an original game name
- Invent a new, original, marketable game name. Do **not** use generic words
  ("Puzzle", "Arrow", "Game") unless fused into something distinctive.
- Replace "Arrow POC" with this name as the screen title **and** app display name.
- Update `appTitle` in both `app_en.arb` and `app_es.arb`.
- Document the chosen name and the rationale in a comment at the top of the
  redesigned screen file.

### 2 — Redesign the main menu screen
Full creative freedom on layout, composition, typography, and hierarchy, as long
as the result reads as a **premium, finished mobile puzzle game** — not a dev POC.
Suggestions (not requirements):
- A subtle, lightweight animated background (gradient sweep, particle drift,
  geometric mesh, or parallax). No heavy video/assets; must stay performant on
  low-end Android (no heavy shaders, no complex physics).
- Bold / minimal / playful typography matched to the chosen name and mood.
- Tactile, responsive buttons (press feedback, depth, or glow).
- **De-emphasize the backend URL** — smaller, lower on screen, or tucked into a
  subtle "Debug" row. It must remain visible/accessible but must not dominate.

### 3 — Preserve all existing functionality
- Play button → `Navigator.pushNamed(AppRoutes.levels)`.
- Settings button → `Navigator.pushNamed(AppRoutes.settings)`.
- Backend URL (`AppConfig.apiBaseUrl`) remains visible/accessible.
- All existing controllers, routes, and navigation arguments untouched.
- Preserve all existing localization keys. Add new keys to **both** ARB files if
  the redesign introduces new text.

### 4 — Assets (only if needed)
- Place any new assets (SVG icons, font files, lightweight Lottie) in
  `assets/menu/` and declare them in `pubspec.yaml`.
- **No external network dependencies.** Total new asset size **< 500 KB**.

### 5 — Update app display name
- Update the Android app label in `android/app/src/main/AndroidManifest.xml`.
- Update `CFBundleDisplayName` / `CFBundleName` in `ios/Runner/Info.plist`.
- Update the `MaterialApp` `title` if applicable.
- Document any manual steps that cannot be automated (e.g. app-icon regen).

---

## Constraints

- Work **only** inside `frontend-poc-arrow/`.
- Do not modify `backend-poc-arrow` or any backend code.
- Do not modify auth, sync, leaderboard, or API code.
- Do not modify game board rendering, arrow shapes/colors, level data, gameplay
  logic, `MovementResolver`, the audio system, or settings functionality.
- Do not change the in-game neon palette (`AppTheme.neon*`). You may reuse those
  colors on the menu if they fit, or introduce menu-specific accent colors that
  harmonize with them.
- **Do NOT add new dependencies without approval.** If a lightweight animation
  package is essential, propose it before touching `pubspec.yaml`.
- Graph-based runtime only — no grid/matrix/tile logic introduced.
- Do not modify Git remotes. Do not regenerate `assets/levels/manual_levels.json`.
- **Stay on branch `feat/phase-20-main-menu-redesign`.** Do not switch branches.
- Do not commit or push. Stage only if ≥ 95% confident. Await Technical Lead
  approval before any commit.

---

## Validation

Run these after implementation. All must pass.

```bash
flutter analyze    # 0 issues
flutter test       # all 122 existing tests pass
```

Manual checks:
- App launches to the redesigned menu; name displays as the new title.
- Play → level selection; Settings → settings. Both navigate correctly.
- Backend URL still visible but visually de-emphasized.
- Background animation is smooth on a low-end Android profile.
- New app display name shows under the launcher icon (Android/iOS).

---

## After Completion

1. Update `docs/CODEX_HANDOFF.md` using `harness/templates/handoff_update_template.md`.
2. Update `harness/context/phase_registry.md` — mark **Phase 20 as COMPLETE**.
3. Update `harness/metrics/improvement_log.md`.

Report:
- The new game name chosen and its rationale.
- List of files changed / created.
- Any new assets added and their sizes.
- Before/after description of the visual changes.

---

Do not be verbose. Be direct.
