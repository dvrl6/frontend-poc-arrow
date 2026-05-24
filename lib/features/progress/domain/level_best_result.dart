class LevelBestResult {
  const LevelBestResult({
    required this.score,
    required this.moves,
    required this.timeSeconds,
  });

  final int score;
  final int moves;
  final int timeSeconds;

  Map<String, Object?> toJson() {
    return {'score': score, 'moves': moves, 'timeSeconds': timeSeconds};
  }

  factory LevelBestResult.fromJson(Map<String, Object?> json) {
    return LevelBestResult(
      score: (json['score'] as num?)?.toInt() ?? 0,
      moves: (json['moves'] as num?)?.toInt() ?? 0,
      timeSeconds: (json['timeSeconds'] as num?)?.toInt() ?? 0,
    );
  }
}
