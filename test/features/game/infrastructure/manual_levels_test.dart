import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_poc_arrow/features/game/application/get_local_level_by_number_use_case.dart';
import 'package:frontend_poc_arrow/features/game/application/get_local_levels_use_case.dart';
import 'package:frontend_poc_arrow/features/game/application/movement_resolver.dart';
import 'package:frontend_poc_arrow/features/game/domain/game_session.dart';
import 'package:frontend_poc_arrow/features/game/domain/level.dart';
import 'package:frontend_poc_arrow/features/game/domain/level_definition_validator.dart';
import 'package:frontend_poc_arrow/features/game/infrastructure/asset_level_repository.dart';
import 'package:frontend_poc_arrow/features/game/infrastructure/asset_text_loader.dart';
import 'package:frontend_poc_arrow/features/game/infrastructure/level_definition_mapper.dart';
import 'package:frontend_poc_arrow/features/game/infrastructure/local_level_data_source.dart';
import 'package:frontend_poc_arrow/features/game/infrastructure/manual_level_dto.dart';

class InMemoryAssetTextLoader implements AssetTextLoader {
  const InMemoryAssetTextLoader(this.source);

  final String source;

  @override
  Future<String> loadString(String assetPath) async {
    return source;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AssetLevelRepository repository;

  setUp(() {
    repository = AssetLevelRepository(
      localLevelDataSource: LocalLevelDataSource(
        assetTextLoader: const RootBundleAssetTextLoader(),
      ),
    );
  });

  test('should_load_15_manual_levels_from_assets', () async {
    final levels = await GetLocalLevelsUseCase(repository)();

    expect(levels, hasLength(15));
    expect(levels.first.number, 1);
    expect(levels.last.number, 15);
  });

  test('should_validate_all_manual_levels', () async {
    final dataSource = LocalLevelDataSource(
      assetTextLoader: const RootBundleAssetTextLoader(),
    );
    final mapper = LevelDefinitionMapper();
    final validator = LevelDefinitionValidator();
    final dtos = await dataSource.loadManualLevels();

    final levels = dtos.map(mapper.toDomain).map(validator.validate).toList();

    expect(levels, hasLength(15));
    expect(levels.every((level) => level.boardGraph.nodes.isNotEmpty), isTrue);
    expect(levels.every((level) => level.boardGraph.edges.isNotEmpty), isTrue);
  });

  test('should_have_progressive_difficulty_across_manual_levels', () async {
    final levels = await GetLocalLevelsUseCase(repository)();

    expect(
      levels.where((level) => level.number! <= 5).map(_difficulty),
      everyElement('easy'),
    );
    expect(
      levels
          .where((level) => level.number! >= 6 && level.number! <= 10)
          .map(_difficulty),
      everyElement('medium'),
    );
    expect(
      levels.where((level) => level.number! >= 11).map(_difficulty),
      everyElement('hard'),
    );
  });

  test('should_have_unique_level_numbers', () async {
    final levels = await GetLocalLevelsUseCase(repository)();
    final numbers = levels.map((level) => level.number).toSet();

    expect(numbers, hasLength(15));
    expect(numbers, containsAll(List<int>.generate(15, (index) => index + 1)));
  });

  test('should_have_unique_level_ids', () async {
    final levels = await GetLocalLevelsUseCase(repository)();
    final ids = levels.map((level) => level.id).toSet();

    expect(ids, hasLength(15));
    expect(ids, contains('manual-001'));
    expect(ids, contains('manual-015'));
  });

  test(
    'should_reject_manual_level_when_required_graph_keys_are_missing',
    () async {
      final source = jsonEncode({
        'levels': [
          {
            'number': 1,
            'name': 'Broken Level',
            'difficulty': 'easy',
            'definitionJson': {
              'edges': <Object?>[],
              'arrows': <Object?>[],
              'blockedEdges': <Object?>[],
              'metadata': {'difficulty': 'easy'},
            },
          },
        ],
      });
      final dataSource = LocalLevelDataSource(
        assetTextLoader: InMemoryAssetTextLoader(source),
      );

      expect(dataSource.loadManualLevels, throwsA(isA<FormatException>()));
    },
  );

  test('should_map_manual_level_definition_to_domain_level', () async {
    final level = await GetLocalLevelByNumberUseCase(repository)(2);

    expect(level, isNotNull);
    expect(level!.number, 2);
    expect(level.id, 'manual-002');
    // Level 2 is now 'L-Turn' with 1 arrow (Phase 9 redesign).
    expect(level.name, 'L-Turn');
    expect(level.arrows, hasLength(1));
    expect(level.metadata['generationType'], 'manual');
  });

  test('should_keep_manual_levels_graph_based_not_matrix_based', () async {
    final source = await const RootBundleAssetTextLoader().loadString(
      LocalLevelDataSource.manualLevelsAssetPath,
    );
    final decoded = jsonDecode(source) as Map<String, Object?>;
    final levels = decoded['levels']! as List<Object?>;

    for (final rawLevel in levels) {
      final level = rawLevel! as Map<String, Object?>;
      final definition = level['definitionJson']! as Map<String, Object?>;
      expect(definition.containsKey('nodes'), isTrue);
      expect(definition.containsKey('edges'), isTrue);
      expect(definition.containsKey('arrows'), isTrue);
      expect(definition.containsKey('blockedEdges'), isTrue);
      expect(definition.containsKey('matrix'), isFalse);
      expect(definition.containsKey('grid'), isFalse);
      expect(definition.containsKey('cells'), isFalse);
    }
  });

  test('should_have_no_free_nodes_at_level_start', () async {
    final levels = await GetLocalLevelsUseCase(repository)();

    for (final level in levels) {
      final covered = <String>{};
      for (final arrow in level.arrows) {
        covered.addAll(
          MovementResolver.coveredNodeIds(level.boardGraph, arrow),
        );
      }
      final free = level.boardGraph.nodes
          .where((node) => !covered.contains(node.id))
          .map((node) => node.id)
          .toList();
      expect(
        free,
        isEmpty,
        reason: 'Level ${level.number} has free (unoccupied) nodes: $free',
      );
    }
  });

  test('should_keep_all_levels_solvable_under_full_exit_resolver', () async {
    final levels = await GetLocalLevelsUseCase(repository)();

    for (final level in levels) {
      expect(
        _isSolvable(GameSession.start(level)),
        isTrue,
        reason: 'Level ${level.number} is not solvable',
      );
    }
  });

  test('should_not_have_all_hard_levels_rectangular', () async {
    final levels = await GetLocalLevelsUseCase(repository)();
    final hard = levels.where((level) => (level.number ?? 0) >= 11).toList();

    final rectangularCount = hard.where(_isRectangular).length;
    expect(
      rectangularCount,
      lessThan(hard.length),
      reason: 'All hard levels are full rectangles',
    );
  });

  test(
    'should_normalize_reversed_undirected_edge_id_when_equivalent_edge_exists',
    () {
      final mapper = LevelDefinitionMapper();
      final validator = LevelDefinitionValidator();

      final definition = mapper.toDomain(_manualLevelWithArrowEdge('b-a'));
      final level = validator.validate(definition);

      expect(definition.arrows.single.occupiedEdgeIds, ['a-b']);
      expect(level.arrows.single.occupiedEdgeIds, ['a-b']);
    },
  );

  test(
    'should_reject_manual_level_when_reversed_edge_reference_does_not_exist',
    () {
      final mapper = LevelDefinitionMapper();

      expect(
        () => mapper.toDomain(_manualLevelWithArrowEdge('c-b')),
        throwsA(isA<FormatException>()),
      );
    },
  );
}

String? _difficulty(Level level) {
  return level.metadata['difficulty'] as String?;
}

bool _isRectangular(Level level) {
  final nodes = level.boardGraph.nodes;
  final xs = nodes.map((n) => n.coordinate.x);
  final ys = nodes.map((n) => n.coordinate.y);
  final w = xs.reduce((a, b) => a > b ? a : b) -
      xs.reduce((a, b) => a < b ? a : b) +
      1;
  final h = ys.reduce((a, b) => a > b ? a : b) -
      ys.reduce((a, b) => a < b ? a : b) +
      1;
  return nodes.length == w * h;
}

/// DFS over exit orders using the real [MovementResolver]: a level is solvable
/// if some order lets every arrow escape.
bool _isSolvable(GameSession session) {
  const resolver = MovementResolver();
  final active = session.activeArrows;
  if (active.isEmpty) {
    return true;
  }
  for (final arrow in active) {
    if (resolver.resolve(session: session, arrow: arrow) ==
        ExitAttemptOutcome.escaped) {
      final next = session.copyWith(
        arrows: session.arrows
            .map(
              (a) => a.id == arrow.id ? a.copyWith(isEscaped: true) : a,
            )
            .toList(growable: false),
      );
      if (_isSolvable(next)) {
        return true;
      }
    }
  }
  return false;
}

ManualLevelDto _manualLevelWithArrowEdge(String occupiedEdgeId) {
  return ManualLevelDto(
    number: 99,
    name: 'Mapper Fixture',
    difficulty: 'easy',
    definitionJson: ManualLevelDefinitionDto(
      nodes: const [
        ManualGraphNodeDto(id: 'a', x: 0, y: 0),
        ManualGraphNodeDto(id: 'b', x: 1, y: 0),
      ],
      edges: const [
        ManualGraphEdgeDto(id: 'a-b', fromNodeId: 'a', toNodeId: 'b'),
      ],
      arrows: [
        ManualArrowPathDto(
          id: 'arrow-1',
          occupiedEdges: [occupiedEdgeId],
          startNodeId: 'a',
          endNodeId: 'b',
          direction: 'right',
        ),
      ],
      blockedEdges: const [],
      metadata: const {
        'difficulty': 'easy',
        'timeLimit': 120,
        'maxMoves': 20,
        'generationType': 'manual',
        'seed': null,
      },
    ),
  );
}
