class LeaderboardEntry {
  const LeaderboardEntry({
    required this.id,
    required this.levelId,
    required this.score,
    required this.moves,
    required this.timeSeconds,
    required this.displayName,
  });

  final String id;
  final String levelId;
  final int score;
  final int moves;
  final int timeSeconds;
  final String displayName;
}
