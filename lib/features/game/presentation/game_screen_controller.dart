import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../audio/application/game_audio_event.dart';
import '../application/game_session_service.dart';
import '../application/movement_result.dart';
import '../domain/game_session.dart';
import '../domain/game_status.dart';
import '../domain/level.dart';
import '../../progress/domain/level_best_result.dart';

typedef LoadLevelByNumber = Future<Level?> Function(int levelNumber);
typedef SaveLevelCompletion =
    Future<void> Function({
      required int levelNumber,
      required int score,
      required int moves,
      required int timeSeconds,
    });
typedef NotifyRemoteLevelCompletion =
    Future<void> Function({
      required int levelNumber,
      required int score,
      required int moves,
      required int timeSeconds,
    });
typedef GetBestLevelResult = Future<LevelBestResult?> Function(int levelNumber);
typedef PlayGameAudio = Future<void> Function(GameAudioEvent event);

enum GameScreenLoadState { loading, ready, notFound, failed }

class GameScreenController extends ChangeNotifier {
  GameScreenController({
    required int? levelNumber,
    required LoadLevelByNumber loadLevelByNumber,
    SaveLevelCompletion? saveLevelCompletion,
    NotifyRemoteLevelCompletion? notifyRemoteLevelCompletion,
    GetBestLevelResult? getBestLevelResult,
    PlayGameAudio? playGameAudio,
    GameSessionService gameSessionService = const GameSessionService(),
  }) : _levelNumber = levelNumber,
       _loadLevelByNumber = loadLevelByNumber,
       _saveLevelCompletion = saveLevelCompletion,
       _notifyRemoteLevelCompletion = notifyRemoteLevelCompletion,
       _getBestLevelResult = getBestLevelResult,
       _playGameAudio = playGameAudio,
       _gameSessionService = gameSessionService;

  final int? _levelNumber;
  final LoadLevelByNumber _loadLevelByNumber;
  final SaveLevelCompletion? _saveLevelCompletion;
  final NotifyRemoteLevelCompletion? _notifyRemoteLevelCompletion;
  final GetBestLevelResult? _getBestLevelResult;
  final PlayGameAudio? _playGameAudio;
  final GameSessionService _gameSessionService;

  GameScreenLoadState _loadState = GameScreenLoadState.loading;
  Level? _level;
  GameSession? _session;
  MovementOutcome? _lastOutcome;
  LevelBestResult? _bestResult;
  bool _completionSaved = false;

  GameScreenLoadState get loadState => _loadState;
  Level? get level => _level;
  GameSession? get session => _session;
  MovementOutcome? get lastOutcome => _lastOutcome;
  LevelBestResult? get bestResult => _bestResult;
  bool get isVictory => _session?.status == GameStatus.victory;

  Future<void> load() async {
    final levelNumber = _levelNumber;
    if (levelNumber == null || levelNumber < 1) {
      _loadState = GameScreenLoadState.notFound;
      notifyListeners();
      return;
    }

    _loadState = GameScreenLoadState.loading;
    notifyListeners();

    try {
      final loadedLevel = await _loadLevelByNumber(levelNumber);
      if (loadedLevel == null) {
        _loadState = GameScreenLoadState.notFound;
        notifyListeners();
        return;
      }

      _level = loadedLevel;
      _session = _gameSessionService.start(loadedLevel);
      _bestResult = await _getBestLevelResult?.call(levelNumber);
      _lastOutcome = null;
      _completionSaved = false;
      _loadState = GameScreenLoadState.ready;
      notifyListeners();
    } catch (_) {
      _loadState = GameScreenLoadState.failed;
      notifyListeners();
    }
  }

  void activateArrow(String arrowId) {
    final currentSession = _session;
    if (currentSession == null || currentSession.status == GameStatus.victory) {
      return;
    }

    final result = _gameSessionService.activateArrow(currentSession, arrowId);
    _session = result.session;
    _lastOutcome = result.outcome;
    unawaited(_playAudioFor(result));
    if (result.session.status == GameStatus.victory) {
      unawaited(_saveCompletionOnce(result.session));
    }
    notifyListeners();
  }

  void restart() {
    final currentLevel = _level;
    if (currentLevel == null) {
      return;
    }

    _session = _gameSessionService.start(currentLevel);
    _lastOutcome = null;
    _completionSaved = false;
    _loadState = GameScreenLoadState.ready;
    notifyListeners();
  }

  Future<void> _saveCompletionOnce(GameSession completedSession) async {
    final levelNumber = completedSession.level.number;
    final saveCompletion = _saveLevelCompletion;
    if (_completionSaved || levelNumber == null || saveCompletion == null) {
      return;
    }

    _completionSaved = true;
    await saveCompletion(
      levelNumber: levelNumber,
      score: completedSession.score.value,
      moves: completedSession.movesCount,
      timeSeconds: completedSession.elapsedSeconds,
    );
    unawaited(_notifyRemoteCompletionBestEffort(completedSession, levelNumber));
    _bestResult = await _getBestLevelResult?.call(levelNumber);
    notifyListeners();
  }

  Future<void> _notifyRemoteCompletionBestEffort(
    GameSession completedSession,
    int levelNumber,
  ) async {
    final notifyRemote = _notifyRemoteLevelCompletion;
    if (notifyRemote == null) {
      return;
    }
    try {
      await notifyRemote(
        levelNumber: levelNumber,
        score: completedSession.score.value,
        moves: completedSession.movesCount,
        timeSeconds: completedSession.elapsedSeconds,
      );
    } catch (_) {
      // Remote sync and leaderboard are best-effort; local victory stays valid.
    }
  }

  Future<void> _playAudioFor(MovementResult result) async {
    final playAudio = _playGameAudio;
    if (playAudio == null) {
      return;
    }

    if (result.session.status == GameStatus.victory) {
      await playAudio(GameAudioEvent.victory);
      return;
    }

    final event = switch (result.outcome) {
      MovementOutcome.moved || MovementOutcome.escaped => GameAudioEvent.move,
      MovementOutcome.blocked ||
      MovementOutcome.occupied ||
      MovementOutcome.arrowNotFound ||
      MovementOutcome.alreadyEscaped => GameAudioEvent.blocked,
    };
    await playAudio(event);
  }
}
