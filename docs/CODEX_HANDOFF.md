# Codex Handoff

## Current Repository

- Repository: `frontend-poc-arrow`
- Branch: `feat/manual-graph-levels`
- Do not modify Git remotes automatically.
- Do not modify `backend-poc-arrow` from this frontend phase.

## Completed Phases

- Phase 3 Flutter Bootstrap: completed and merged before this branch.
- Phase 4 Graph-Based Game Engine Domain: completed and merged before this branch.
- Phase 5 Manual Graph-Based Levels: local level assets and loading infrastructure implemented.

## Implemented Phase 5 State

- Added `assets/levels/manual_levels.json`.
- Registered the level asset in `pubspec.yaml`.
- Mirrored the backend manual level seed shape with `number`, `name`, `difficulty`, and `definitionJson`.
- Added 15 deterministic hand-authored graph-based levels.
- Preserved level numbers from 1 to 15.
- Added local loading through infrastructure, not domain.
- Added application-level repository port and use cases for all manual levels and lookup by level number.
- Added tests that load the real registered asset and validate all 15 levels.
- Added focused tests for reversed undirected edge id normalization and invalid reversed edge rejection.

## Important Constraints

- Flutter owns gameplay logic.
- Backend does not process every move.
- Game levels are graph-based JSON, not matrix-only.
- `DottedBoardPlaceholder` is presentation-only and is not the game engine.
- Phase 5 did not implement gameplay UI.
- Phase 5 did not implement backend integration.
- Phase 5 did not implement random level generation.
- Phase 5 did not build an APK.

## Local Level Asset

Asset path:

```text
assets/levels/manual_levels.json
```

Shape:

```json
{
  "levels": [
    {
      "number": 1,
      "name": "First Exit",
      "difficulty": "easy",
      "definitionJson": {
        "nodes": [],
        "edges": [],
        "arrows": [],
        "blockedEdges": [],
        "metadata": {}
      }
    }
  ]
}
```

Difficulty progression:

- Levels 1-5: easy.
- Levels 6-10: medium.
- Levels 11-15: hard.

## Backend Compatibility

The frontend asset mirrors `backend-poc-arrow/prisma/levels/manual-levels.ts` as closely as possible without modifying backend files. The backend seed stores undirected graph edges with backend-generated ids.

`LevelDefinitionMapper` handles compatibility before domain validation:

- `arrows[].occupiedEdges` from the asset are normalized into domain `occupiedEdgeIds`.
- `blockedEdges` from the asset are normalized into domain `blockedEdgeIds`.
- Edge definitions themselves are not normalized or rewritten.
- Nodes, arrow start/end nodes, direction, name, number, and metadata are not edge-normalized.

Normalization is safe because it only succeeds when either:

- The referenced edge id already exists in `definitionJson.edges`.
- The reversed edge id exists in `definitionJson.edges`.

If neither the exact edge id nor its reversed equivalent exists, the mapper throws `FormatException`. This keeps backend compatibility for undirected edge references without accepting nonexistent graph paths.

## Domain and Application Notes

- `Level` and `LevelDefinition` now preserve optional `number`.
- `LevelRepository` is an application port.
- `GetLocalLevelsUseCase` loads all local manual levels.
- `GetLocalLevelByNumberUseCase` loads one local manual level by number.
- `LevelDefinitionValidator` is still used after mapping and remains structural only.
- `LevelDefinitionValidator` rejects missing blocked edge ids and arrow occupied edge ids after mapping.
- No puzzle solving, beatability validation, random generation, or move-by-move backend logic was added.

## Infrastructure Added

- `AssetTextLoader`
- `RootBundleAssetTextLoader`
- `LocalLevelDataSource`
- `ManualLevelCollectionDto`
- `ManualLevelDto`
- `LevelDefinitionMapper`
- `AssetLevelRepository`

## Tests Added

- `should_load_15_manual_levels_from_assets`
- `should_validate_all_manual_levels`
- `should_have_progressive_difficulty_across_manual_levels`
- `should_have_unique_level_numbers`
- `should_have_unique_level_ids`
- `should_reject_manual_level_when_required_graph_keys_are_missing`
- `should_map_manual_level_definition_to_domain_level`
- `should_keep_manual_levels_graph_based_not_matrix_based`
- `should_normalize_reversed_undirected_edge_id_when_equivalent_edge_exists`
- `should_reject_manual_level_when_reversed_edge_reference_does_not_exist`

## Verification Results

- `flutter pub get`: passed.
- `flutter analyze`: passed.
- `flutter test`: passed with 23 tests.
- Tests include real asset loading from `assets/levels/manual_levels.json`.
- Backend repository remained untouched.
- Git remotes were not modified.

## Next Recommended Phase

Recommended next phase: Phase 6 gameplay UI integration using the existing graph engine and local manual level loader.

Suggested next steps:

- Build a real level selection flow around local manual levels.
- Create a gameplay screen adapter/view model for `GameSession`.
- Keep rendering separate from domain rules.
- Add backend level fetching later as an optional remote source, not as the owner of gameplay.
- Do not add random level generation until manual levels are playable through the UI.

## Files Future Codex Sessions Should Inspect First

- `README.md`
- `AI_USAGE.md`
- `assets/levels/manual_levels.json`
- `lib/features/game/domain/level_definition_validator.dart`
- `lib/features/game/infrastructure/local_level_data_source.dart`
- `lib/features/game/infrastructure/level_definition_mapper.dart`
- `lib/features/game/infrastructure/asset_level_repository.dart`
- `lib/features/game/application/level_repository.dart`
- `test/features/game/infrastructure/manual_levels_test.dart`
