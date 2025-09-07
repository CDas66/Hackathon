class UserData {
  final String username;
  final int health;
  final int steps;
  final int streak;
  final int score;

  UserData({
    required this.username,
    required this.health,
    required this.steps,
    required this.streak,
    required this.score,
  });

  Map<String, dynamic> toMap() {
    return {
      'username':
          username, // include username in map too if you want to store it
      'health': health,
      'steps': steps,
      'streak': streak,
      'score': score,
    };
  }

  factory UserData.fromMap(String username, Map<String, dynamic>? map) {
    if (map == null) {
      return UserData(
        username: username,
        health: 0,
        steps: 0,
        streak: 0,
        score: 0,
      );
    }
    return UserData(
      username: username,
      health: map['health'] ?? 0,
      steps: map['steps'] ?? 0,
      streak: map['streak'] ?? 0,
      score: map['score'] ?? 0,
    );
  }

  UserData copyWith({
    String? username,
    int? health,
    int? steps,
    int? streak,
    int? score,
  }) {
    return UserData(
      username: username ?? this.username,
      health: health ?? this.health,
      steps: steps ?? this.steps,
      streak: streak ?? this.streak,
      score: score ?? this.score,
    );
  }
}
