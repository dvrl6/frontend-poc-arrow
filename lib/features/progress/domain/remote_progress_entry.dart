class RemoteProgressEntry {
  const RemoteProgressEntry({
    required this.levelId,
    required this.completed,
    required this.bestScore,
    required this.bestMoves,
    required this.bestTimeSeconds,
  });

  final String levelId;
  final bool completed;
  final int? bestScore;
  final int? bestMoves;
  final int? bestTimeSeconds;
}
