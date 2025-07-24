class UserScore {
  final int score;
  final DateTime time;

  UserScore({required this.score, required this.time});

   factory UserScore.fromMap(Map<String, dynamic> data) {
    return UserScore(
      score: data['score'], 
      time: data['time'],
    );
  }
}
