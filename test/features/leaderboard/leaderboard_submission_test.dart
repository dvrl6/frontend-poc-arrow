import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_poc_arrow/features/auth/application/token_storage.dart';
import 'package:frontend_poc_arrow/features/auth/domain/auth_session.dart';
import 'package:frontend_poc_arrow/features/auth/domain/authenticated_user.dart';
import 'package:frontend_poc_arrow/features/leaderboard/application/leaderboard_repository.dart';
import 'package:frontend_poc_arrow/features/leaderboard/application/submit_leaderboard_score_use_case.dart';
import 'package:frontend_poc_arrow/features/leaderboard/domain/leaderboard_entry.dart';
import 'package:frontend_poc_arrow/features/progress/application/remote_level_repository.dart';

void main() {
  test(
    'should_submit_leaderboard_when_level_is_completed_and_user_is_authenticated',
    () async {
      final repository = _FakeLeaderboardRepository();
      final useCase = SubmitLeaderboardScoreUseCase(
        leaderboardRepository: repository,
        remoteLevelRepository: _FakeRemoteLevelRepository(),
        tokenStorage: _FakeTokenStorage(authenticated: true),
      );

      final submitted = await useCase(
        levelNumber: 1,
        score: 990,
        moves: 1,
        timeSeconds: 0,
      );

      expect(submitted, isTrue);
      expect(repository.submittedLevelId, 'remote-level-1');
    },
  );

  test(
    'should_skip_leaderboard_submission_when_user_is_not_authenticated',
    () async {
      final repository = _FakeLeaderboardRepository();
      final useCase = SubmitLeaderboardScoreUseCase(
        leaderboardRepository: repository,
        remoteLevelRepository: _FakeRemoteLevelRepository(),
        tokenStorage: _FakeTokenStorage(authenticated: false),
      );

      final submitted = await useCase(
        levelNumber: 1,
        score: 990,
        moves: 1,
        timeSeconds: 0,
      );

      expect(submitted, isFalse);
      expect(repository.submittedLevelId, isNull);
    },
  );
}

class _FakeRemoteLevelRepository implements RemoteLevelRepository {
  @override
  Future<Map<int, String>> getLevelIdsByNumber() async {
    return const {1: 'remote-level-1'};
  }
}

class _FakeLeaderboardRepository implements LeaderboardRepository {
  String? submittedLevelId;

  @override
  Future<List<LeaderboardEntry>> getForLevel(String levelId) async {
    return const <LeaderboardEntry>[];
  }

  @override
  Future<void> submitScore({
    required String levelId,
    required int score,
    required int moves,
    required int timeSeconds,
  }) async {
    submittedLevelId = levelId;
  }
}

class _FakeTokenStorage implements TokenStorage {
  _FakeTokenStorage({required this.authenticated});

  final bool authenticated;

  @override
  Future<void> clearSession() async {}

  @override
  Future<String?> getAccessToken() async => authenticated ? 'token' : null;

  @override
  Future<AuthSession?> getSession() async => authenticated
      ? const AuthSession(
          accessToken: 'token',
          user: AuthenticatedUser(
            id: 'user-1',
            email: 'player@example.com',
            displayName: 'Player',
            role: 'PLAYER',
          ),
        )
      : null;

  @override
  Future<void> saveSession(AuthSession session) async {}
}
