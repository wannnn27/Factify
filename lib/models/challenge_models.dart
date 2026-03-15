/// Enum untuk tingkat kesulitan challenge
enum ChallengeDifficulty {
  pemula,     // Level 1 - untuk Pelajar
  menengah,   // Level 2 - untuk Mahasiswa
  lanjutan,   // Level 3 - untuk Pekerja/Profesional
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
    return ChallengeResult(
      score: json['score'] ?? 0,
      verdict: json['verdict'] ?? 'Belum dinilai',
      strengths: List<String>.from(json['strengths'] ?? []),
      weaknesses: List<String>.from(json['weaknesses'] ?? []),
      feedback: json['feedback'] ?? '',
      detailedScores: json['detailed_scores'] ?? {},
    );
  }
}
