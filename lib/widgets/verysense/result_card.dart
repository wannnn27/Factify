
import 'package:flutter/material.dart';
import '../../models/verification_result.dart';

/// Card untuk menampilkan skor kredibilitas
class CredibilityScoreCard extends StatelessWidget {
  final double score;
  final CredibilityStatus status;
  final Color statusColor;
  final double? confidence;

  const CredibilityScoreCard({
    super.key,
    required this.score,
    required this.status,
    required this.statusColor,
    this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xF2FFFFFF),
            Color(0xE6FFFFFF),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: statusColor.withAlpha(77),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Skor Kredibilitas',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
              Column(
                children: [
                  Text(
                    '${score.round()}',
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                      height: 1,
                    ),
                  ),
                  const Text(
                    '/100',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withAlpha(102),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(status.icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  status.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (confidence != null) ...[
            const SizedBox(height: 12),
            Text(
              'Confidence: ${(confidence! * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Card untuk menampilkan sumber analisis
class SourceInfoCard extends StatelessWidget {
  final ContentType contentType;
  final String source;

  const SourceInfoCard({
    super.key,
    required this.contentType,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0x992D2D44),
            Color(0x662D2D44),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white10,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(contentType.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sumber ${contentType.displayName}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  source,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Card yang bisa di-expand untuk menampilkan detail
class ExpandableInfoCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final bool isExpanded;
  final VoidCallback onTap;
  final Color? accentColor;

  const ExpandableInfoCard({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    required this.isExpanded,
    required this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? const Color(0xFF4ECDC4);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0x992D2D44),
                Color(0x662D2D44),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isExpanded ? color.withAlpha(77) : Colors.white10,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withAlpha(51),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: color,
                      size: 24,
                    ),
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: isExpanded
                    ? Column(
                        children: [
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              content,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card untuk menampilkan analisis detail video
class VideoAnalysisCard extends StatelessWidget {
  final VideoAnalysisDetail detail;

  const VideoAnalysisCard({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0x266C5CE7),
            Color(0x0D6C5CE7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0x4D6C5CE7),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFF5B4FCE)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Icon(Icons.analytics, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'Analisis Detail Video',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAnalysisItem(
            'Deepfake Detection',
            detail.deepfakeScore,
            _getScoreColor(detail.deepfakeScore, inverse: true),
          ),
          _buildAnalysisItem(
            'Audio Authenticity',
            detail.audioAuthenticity,
            _getScoreColor(detail.audioAuthenticity),
          ),
          _buildAnalysisItem(
            'Metadata Integrity',
            detail.metadataIntegrity,
            _getScoreColor(detail.metadataIntegrity),
          ),
          _buildAnalysisItem(
            'Visual Consistency',
            detail.visualConsistency,
            _getScoreColor(detail.visualConsistency),
          ),
          _buildAnalysisItem(
            'Temporal Consistency',
            detail.temporalConsistency,
            _getScoreColor(detail.temporalConsistency),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score, {bool inverse = false}) {
    if (inverse) {
      if (score <= 30) return const Color(0xFF4ECDC4);
      if (score <= 60) return const Color(0xFFFFD93D);
      return const Color(0xFFFF6B6B);
    } else {
      if (score >= 70) return const Color(0xFF4ECDC4);
      if (score >= 40) return const Color(0xFFFFD93D);
      return const Color(0xFFFF6B6B);
    }
  }

  Widget _buildAnalysisItem(String label, double score, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              Text(
                '${score.round()}%',
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card untuk menampilkan analisis detail gambar
class ImageAnalysisCard extends StatelessWidget {
  final ImageAnalysisDetail detail;

  const ImageAnalysisCard({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0x264ECDC4),
            Color(0x0D4ECDC4),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0x4D4ECDC4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image_search,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'Analisis Detail Gambar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'ELA Analysis',
            '${detail.elaScore.round()}%',
            _getScoreColor(detail.elaScore),
          ),
          _buildInfoRow(
            'Manipulation Score',
            '${detail.manipulationScore.round()}%',
            _getScoreColor(detail.manipulationScore, inverse: true),
          ),
          if (detail.isAiGenerated)
            _buildInfoRow(
              'AI Generated',
              'Yes (${(detail.aiGeneratedConfidence * 100).round()}%)',
              const Color(0xFFFF6B6B),
            ),
          if (detail.copyMoveDetected)
            _buildInfoRow(
              'Copy-Move Detected',
              'Yes',
              const Color(0xFFFFD93D),
            ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score, {bool inverse = false}) {
    if (inverse) {
      if (score <= 30) return const Color(0xFF4ECDC4);
      if (score <= 60) return const Color(0xFFFFD93D);
      return const Color(0xFFFF6B6B);
    } else {
      if (score >= 70) return const Color(0xFF4ECDC4);
      if (score >= 40) return const Color(0xFFFFD93D);
      return const Color(0xFFFF6B6B);
    }
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withAlpha(51),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card untuk menampilkan analisis detail teks
class TextAnalysisCard extends StatelessWidget {
  final TextAnalysisDetail detail;

  const TextAnalysisCard({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0x265B9BD5),
            Color(0x0D5B9BD5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0x4D5B9BD5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5B9BD5), Color(0xFF4A8AC4)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.text_snippet,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'Analisis Detail Teks',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAnalysisBar('Hoax Score', detail.hoaxScore, inverse: true),
          _buildAnalysisBar('Clickbait Score', detail.clickbaitScore,
              inverse: true),
          _buildAnalysisBar('Credibility Score', detail.credibilityScore),
          const SizedBox(height: 8),
          _buildInfoChip('Sentiment', detail.sentimentLabel.toUpperCase(),
              _getSentimentColor(detail.sentimentLabel)),
          const SizedBox(height: 4),
          _buildInfoChip(
              'Word Count', '${detail.wordCount} words', const Color(0xFF5B9BD5)),
        ],
      ),
    );
  }

  Color _getSentimentColor(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'positive':
        return const Color(0xFF4ECDC4);
      case 'negative':
        return const Color(0xFFFF6B6B);
      default:
        return const Color(0xFFFFD93D);
    }
  }

  Color _getScoreColor(double score, {bool inverse = false}) {
    if (inverse) {
      if (score <= 30) return const Color(0xFF4ECDC4);
      if (score <= 60) return const Color(0xFFFFD93D);
      return const Color(0xFFFF6B6B);
    } else {
      if (score >= 70) return const Color(0xFF4ECDC4);
      if (score >= 40) return const Color(0xFFFFD93D);
      return const Color(0xFFFF6B6B);
    }
  }

  Widget _buildAnalysisBar(String label, double score, {bool inverse = false}) {
    final color = _getScoreColor(score, inverse: inverse);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              Text(
                '${score.round()}%',
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withAlpha(51),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
