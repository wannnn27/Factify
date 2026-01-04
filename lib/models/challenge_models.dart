
class ChallengeCase {
  final String id;
  final String topic;
  final String title;
  final String imageUrl;
  final String background;
  final String problem;
  final String solution; // Hidden from user, sent to AI for verification

  const ChallengeCase({
    required this.id,
    required this.topic,
    required this.title,
    required this.imageUrl,
    required this.background,
    required this.problem,
    required this.solution,
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
