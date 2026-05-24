/// Enum untuk tingkat kesulitan challenge
enum ChallengeDifficulty {
  pemula, // Level 1 - untuk Pelajar
  menengah, // Level 2 - untuk Mahasiswa
  lanjutan, // Level 3 - untuk Pekerja/Profesional
}

extension ChallengeDifficultyExtension on ChallengeDifficulty {
  int get level {
    switch (this) {
      case ChallengeDifficulty.pemula:
        return 1;
      case ChallengeDifficulty.menengah:
        return 2;
      case ChallengeDifficulty.lanjutan:
        return 3;
    }
  }

  String get displayName {
    switch (this) {
      case ChallengeDifficulty.pemula:
        return 'Pemula';
      case ChallengeDifficulty.menengah:
        return 'Menengah';
      case ChallengeDifficulty.lanjutan:
        return 'Lanjutan';
    }
  }

  String get description {
    switch (this) {
      case ChallengeDifficulty.pemula:
        return 'Cocok untuk pelajar, kasus sederhana dengan petunjuk jelas';
      case ChallengeDifficulty.menengah:
        return 'Untuk mahasiswa, membutuhkan analisis lebih mendalam';
      case ChallengeDifficulty.lanjutan:
        return 'Untuk profesional, kasus kompleks dan nuansa halus';
    }
  }
}

class ChallengeCase {
  final String id;
  final String topic;
  final String title;
  final String imageUrl;
  final String background;
  final String problem;
  final String solution; // Hidden from user, sent to AI for verification
  final ChallengeDifficulty difficulty; // Tingkat kesulitan challenge

  const ChallengeCase({
    required this.id,
    required this.topic,
    required this.title,
    required this.imageUrl,
    required this.background,
    required this.problem,
    required this.solution,
    this.difficulty = ChallengeDifficulty.pemula, // Default pemula
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topic': topic,
      'title': title,
      'imageUrl': imageUrl,
      'background': background,
      'problem': problem,
      'solution': solution,
      'difficulty': difficulty.level,
    };
  }
}

class ChallengeResult {
  final int score;
  final String verdict;
  final List<String> strengths;
  final List<String> weaknesses;
  final String feedback;
  final Map<String, dynamic> detailedScores;

  ChallengeResult({
    required this.score,
    required this.verdict,
    required this.strengths,
    required this.weaknesses,
    required this.feedback,
    required this.detailedScores,
  });

  factory ChallengeResult.fromJson(Map<String, dynamic> json) {
    int parseScore(dynamic value) {
      if (value is int) return value.clamp(0, 100).toInt();
      if (value is num) return value.round().clamp(0, 100).toInt();
      if (value is String) {
        return (num.tryParse(value)?.round() ?? 0).clamp(0, 100).toInt();
      }
      return 0;
    }

    List<String> parseStringList(dynamic value) {
      if (value is List) {
        return value.map((item) => item.toString()).toList();
      }
      return const [];
    }

    Map<String, dynamic> parseScores(dynamic value) {
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
      return const {};
    }

    return ChallengeResult(
      score: parseScore(json['score']),
      verdict: json['verdict']?.toString() ?? 'Belum dinilai',
      strengths: parseStringList(json['strengths']),
      weaknesses: parseStringList(json['weaknesses']),
      feedback: json['feedback']?.toString() ?? '',
      detailedScores: parseScores(json['detailed_scores']),
    );
  }
}
