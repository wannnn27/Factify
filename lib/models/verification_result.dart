
import 'package:flutter/material.dart';

/// Status kredibilitas hasil verifikasi
enum CredibilityStatus {
  kredibel,
  cukupKredibel,
  perluPerhatian,
  tidakKredibel,
}

/// Extension untuk mendapatkan properti dari CredibilityStatus
extension CredibilityStatusExtension on CredibilityStatus {
  String get label {
    switch (this) {
      case CredibilityStatus.kredibel:
        return 'Kredibel';
      case CredibilityStatus.cukupKredibel:
        return 'Cukup Kredibel';
      case CredibilityStatus.perluPerhatian:
        return 'Perlu Perhatian';
      case CredibilityStatus.tidakKredibel:
        return 'Tidak Kredibel';
    }
  }

  Color get color {
    switch (this) {
      case CredibilityStatus.kredibel:
        return const Color(0xFF4ECDC4);
      case CredibilityStatus.cukupKredibel:
        return const Color(0xFF4ECDC4);
      case CredibilityStatus.perluPerhatian:
        return const Color(0xFFFFD93D);
      case CredibilityStatus.tidakKredibel:
        return const Color(0xFFFF6B6B);
    }
  }

  IconData get icon {
    switch (this) {
      case CredibilityStatus.kredibel:
        return Icons.verified;
      case CredibilityStatus.cukupKredibel:
        return Icons.check_circle;
      case CredibilityStatus.perluPerhatian:
        return Icons.warning;
      case CredibilityStatus.tidakKredibel:
        return Icons.dangerous;
    }
  }
}

/// Tipe konten yang diverifikasi
enum ContentType {
  text,
  url,
  image,
  video,
}

extension ContentTypeExtension on ContentType {
  String get value {
    switch (this) {
      case ContentType.text:
        return 'text';
      case ContentType.url:
        return 'url';
      case ContentType.image:
        return 'image';
      case ContentType.video:
        return 'video';
    }
  }

  String get displayName {
    switch (this) {
      case ContentType.text:
        return 'Teks';
      case ContentType.url:
        return 'URL';
      case ContentType.image:
        return 'Gambar';
      case ContentType.video:
        return 'Video';
    }
  }

  IconData get icon {
    switch (this) {
      case ContentType.text:
        return Icons.text_fields;
      case ContentType.url:
        return Icons.link;
      case ContentType.image:
        return Icons.image;
      case ContentType.video:
        return Icons.videocam;
    }
  }
}

/// Model untuk detail analisis video
class VideoAnalysisDetail {
  final double deepfakeScore;
  final double audioAuthenticity;
  final double metadataIntegrity;
  final double visualConsistency;
  final double temporalConsistency;
  final bool isDeepfake;
  final double deepfakeConfidence;
  final Map<String, dynamic> additionalData;

  VideoAnalysisDetail({
    required this.deepfakeScore,
    required this.audioAuthenticity,
    required this.metadataIntegrity,
    required this.visualConsistency,
    required this.temporalConsistency,
    this.isDeepfake = false,
    this.deepfakeConfidence = 0.0,
    this.additionalData = const {},
  });

  factory VideoAnalysisDetail.fromJson(Map<String, dynamic> json) {
    final deepfakeAnalysis = json['deepfake_analysis'] is Map
        ? Map<String, dynamic>.from(json['deepfake_analysis'] as Map)
        : <String, dynamic>{};
    final audioAnalysis = json['audio_analysis'] is Map
        ? json['audio_analysis'] as Map<String, dynamic>
        : null;
    final visualAnalysis = json['visual_analysis'] is Map
        ? json['visual_analysis'] as Map<String, dynamic>
        : null;

    return VideoAnalysisDetail(
      deepfakeScore: _safeDouble(json['deepfake_score'], deepfakeAnalysis['confidence'], 0.0) * 100,
      audioAuthenticity: _safeDouble(json['audio_authenticity'], audioAnalysis?['score'], 0.6) * 100,
      metadataIntegrity: _safeDouble(json['metadata_integrity'], null, 0.75) * 100,
      visualConsistency: _safeDouble(json['visual_consistency'], visualAnalysis?['consistency_score'], 0.7) * 100,
      temporalConsistency: _safeDouble(json['temporal_consistency'], null, 0.8) * 100,
      isDeepfake: _safeBool(deepfakeAnalysis['is_deepfake'], false),
      deepfakeConfidence: _safeDouble(deepfakeAnalysis['confidence'], null, 0.0),
      additionalData: json,
    );
  }

  static double _safeDouble(dynamic primary, dynamic secondary, double fallback) {
    final v = primary ?? secondary;
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  static bool _safeBool(dynamic value, bool fallback) {
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return fallback;
  }
}

/// Model untuk detail analisis gambar
class ImageAnalysisDetail {
  final double elaScore;
  final double manipulationScore;
  final bool isAiGenerated;
  final double aiGeneratedConfidence;
  final bool copyMoveDetected;
  final Map<String, dynamic> exifData;
  final Map<String, dynamic> additionalData;

  ImageAnalysisDetail({
    required this.elaScore,
    required this.manipulationScore,
    this.isAiGenerated = false,
    this.aiGeneratedConfidence = 0.0,
    this.copyMoveDetected = false,
    this.exifData = const {},
    this.additionalData = const {},
  });

  factory ImageAnalysisDetail.fromJson(Map<String, dynamic> json) {
    final aiGenerated = json['ai_generated'] as Map<String, dynamic>? ?? {};
    
    return ImageAnalysisDetail(
      elaScore: (json['ela_score'] ?? json['ela']?['mean_ela'] ?? 0.5).toDouble() * 100,
      manipulationScore: (json['manipulation_score'] ?? 0.3).toDouble() * 100,
      isAiGenerated: aiGenerated['is_ai_generated'] ?? false,
      aiGeneratedConfidence: (aiGenerated['confidence'] ?? 0.0).toDouble(),
      copyMoveDetected: json['copy_move_detected'] ?? false,
      exifData: json['exif'] as Map<String, dynamic>? ?? {},
      additionalData: json,
    );
  }
}

/// Model untuk detail analisis URL
class UrlAnalysisDetail {
  final String domain;
  final bool sslEnabled;
  final double domainScore;
  final int? domainAgeYears;
  final bool isTrustedDomain;
  final List<String> suspiciousPatterns;
  final Map<String, dynamic> additionalData;

  UrlAnalysisDetail({
    required this.domain,
    required this.sslEnabled,
    required this.domainScore,
    this.domainAgeYears,
    this.isTrustedDomain = false,
    this.suspiciousPatterns = const [],
    this.additionalData = const {},
  });

  factory UrlAnalysisDetail.fromJson(Map<String, dynamic> json) {
    return UrlAnalysisDetail(
      domain: json['domain'] ?? '',
      sslEnabled: json['ssl_enabled'] ?? false,
      domainScore: (json['domain_score'] ?? 0.5).toDouble() * 100,
      domainAgeYears: json['domain_age']?['age_years'],
      isTrustedDomain: json['is_trusted_domain'] ?? false,
      suspiciousPatterns: List<String>.from(json['suspicious_patterns'] ?? []),
      additionalData: json,
    );
  }
}

/// Model untuk detail analisis teks
class TextAnalysisDetail {
  final double hoaxScore;
  final double clickbaitScore;
  final double credibilityScore;
  final String sentimentLabel;
  final double sentimentScore;
  final int wordCount;
  final Map<String, dynamic> additionalData;

  TextAnalysisDetail({
    required this.hoaxScore,
    required this.clickbaitScore,
    required this.credibilityScore,
    required this.sentimentLabel,
    required this.sentimentScore,
    required this.wordCount,
    this.additionalData = const {},
  });

  factory TextAnalysisDetail.fromJson(Map<String, dynamic> json) {
    final sentiment = json['sentiment'] as Map<String, dynamic>? ?? {};
    
    return TextAnalysisDetail(
      hoaxScore: (json['hoax_score'] ?? 0.0).toDouble() * 100,
      clickbaitScore: (json['clickbait_score'] ?? 0.0).toDouble() * 100,
      credibilityScore: (json['credibility_score'] ?? 0.0).toDouble() * 100,
      sentimentLabel: sentiment['label'] ?? 'neutral',
      sentimentScore: (sentiment['score'] ?? 0.5).toDouble(),
      wordCount: json['word_count'] ?? 0,
      additionalData: json,
    );
  }
}

/// Model utama untuk hasil verifikasi
class VerificationResult {
  final String requestId;
  final ContentType contentType;
  final double score;
  final double confidence;
  final CredibilityStatus status;
  final Color statusColor;
  final String source;
  final String aiSummary;
  final String mainFindings;
  final String needAttention;
  final String aboutSource;
  final Map<String, dynamic> detailedAnalysis;
  final double analysisTime;
  final DateTime timestamp;
  
  // Type-specific analysis details
  final TextAnalysisDetail? textDetail;
  final UrlAnalysisDetail? urlDetail;
  final ImageAnalysisDetail? imageDetail;
  final VideoAnalysisDetail? videoDetail;

  VerificationResult({
    required this.requestId,
    required this.contentType,
    required this.score,
    required this.confidence,
    required this.status,
    required this.statusColor,
    required this.source,
    required this.aiSummary,
    required this.mainFindings,
    required this.needAttention,
    required this.aboutSource,
    required this.detailedAnalysis,
    required this.analysisTime,
    required this.timestamp,
    this.textDetail,
    this.urlDetail,
    this.imageDetail,
    this.videoDetail,
  });

  /// Parse status string ke enum
  static CredibilityStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'kredibel':
        return CredibilityStatus.kredibel;
      case 'cukup kredibel':
        return CredibilityStatus.cukupKredibel;
      case 'perlu perhatian':
        return CredibilityStatus.perluPerhatian;
      case 'tidak kredibel':
        return CredibilityStatus.tidakKredibel;
      default:
        return CredibilityStatus.perluPerhatian;
    }
  }

  /// Parse content type string ke enum
  static ContentType _parseContentType(String type) {
    switch (type.toLowerCase()) {
      case 'text':
        return ContentType.text;
      case 'url':
        return ContentType.url;
      case 'image':
        return ContentType.image;
      case 'video':
        return ContentType.video;
      default:
        return ContentType.text;
    }
  }

  /// Parse hex color string ke Color
  static Color _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return const Color(0xFF4ECDC4);
    }
    
    // Remove # if present
    String hex = hexColor.replaceAll('#', '');
    
    // Add FF for alpha if not present
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    
    try {
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return const Color(0xFF4ECDC4);
    }
  }

  /// Safe parse double from JSON (int, double, or string).
  static double _safeDoubleFromJson(dynamic value, double fallback) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  /// Factory constructor untuk membuat dari JSON response
  factory VerificationResult.fromJson(Map<String, dynamic> json) {
    final contentTypeStr = json['content_type'] is String ? json['content_type'] as String : 'text';
    final contentType = _parseContentType(contentTypeStr);
    final rawDetailed = json['detailed_analysis'];
    final detailedAnalysis = rawDetailed is Map
        ? Map<String, dynamic>.from(rawDetailed as Map)
        : <String, dynamic>{};
    final score = _safeDoubleFromJson(json['score'], 50.0);
    
    // Parse type-specific details
    TextAnalysisDetail? textDetail;
    UrlAnalysisDetail? urlDetail;
    ImageAnalysisDetail? imageDetail;
    VideoAnalysisDetail? videoDetail;
    
    switch (contentType) {
      case ContentType.text:
        textDetail = TextAnalysisDetail.fromJson(detailedAnalysis);
        break;
      case ContentType.url:
        urlDetail = UrlAnalysisDetail.fromJson(detailedAnalysis);
        break;
      case ContentType.image:
        imageDetail = ImageAnalysisDetail.fromJson(detailedAnalysis);
        break;
      case ContentType.video:
        videoDetail = VideoAnalysisDetail.fromJson(detailedAnalysis);
        break;
    }
    
    // Generate default values jika kosong
    final aiSummary = _getDefaultIfEmpty(
      json['ai_summary'],
      _generateDefaultAiSummary(contentType, score, detailedAnalysis),
    );
    
    final mainFindings = _getDefaultIfEmpty(
      json['main_findings'],
      _generateDefaultFindings(contentType, score, detailedAnalysis),
    );
    
    final needAttention = _getDefaultIfEmpty(
      json['need_attention'],
      _generateDefaultWarnings(contentType, score, detailedAnalysis),
    );
    
    final aboutSource = _getDefaultIfEmpty(
      json['about_source'],
      _generateDefaultSourceInfo(contentType, json['source'] ?? '', detailedAnalysis),
    );
    
    return VerificationResult(
      requestId: json['request_id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      contentType: contentType,
      score: score,
      confidence: _safeDoubleFromJson(json['confidence'], 0.7),
      status: _parseStatus(json['status']?.toString() ?? ''),
      statusColor: _parseColor(json['status_color']?.toString()),
      source: json['source']?.toString() ?? 'Sumber tidak diketahui',
      aiSummary: aiSummary,
      mainFindings: mainFindings,
      needAttention: needAttention,
      aboutSource: aboutSource,
      detailedAnalysis: detailedAnalysis,
      analysisTime: _safeDoubleFromJson(json['analysis_time'], 0.0),
      timestamp: json['timestamp'] != null 
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      textDetail: textDetail,
      urlDetail: urlDetail,
      imageDetail: imageDetail,
      videoDetail: videoDetail,
    );
  }
  
  /// Helper untuk mendapatkan default jika string kosong
  static String _getDefaultIfEmpty(dynamic value, String defaultValue) {
    if (value == null || value.toString().trim().isEmpty) {
      return defaultValue;
    }
    return value.toString();
  }
  
  /// Generate default AI summary berdasarkan score dan content type
  static String _generateDefaultAiSummary(ContentType contentType, double score, Map<String, dynamic> data) {
    String summary;
    
    if (score >= 80) {
      summary = '✅ Konten ini memiliki tingkat kredibilitas tinggi. ';
    } else if (score >= 60) {
      summary = '⚠️ Konten ini cukup kredibel dengan beberapa catatan. ';
    } else if (score >= 40) {
      summary = '🔍 Konten ini memerlukan verifikasi lebih lanjut. ';
    } else {
      summary = '❌ Konten ini memiliki banyak indikator yang perlu diperhatikan. ';
    }
    
    switch (contentType) {
      case ContentType.text:
        final hoaxScore = (data['hoax_score'] ?? 0.0) as num;
        final clickbaitScore = (data['clickbait_score'] ?? 0.0) as num;
        if (hoaxScore > 0.5) {
          summary += 'Terdeteksi beberapa indikator konten yang menyesatkan. ';
        }
        if (clickbaitScore > 0.5) {
          summary += 'Pola penulisan clickbait terdeteksi. ';
        }
        summary += 'Selalu verifikasi informasi dari sumber terpercaya.';
        break;
      case ContentType.url:
        final sslEnabled = data['ssl_enabled'] ?? false;
        if (sslEnabled == true) {
          summary += 'Website menggunakan koneksi aman (HTTPS). ';
        }
        summary += 'Pastikan untuk memeriksa kredibilitas domain.';
        break;
      case ContentType.image:
        final aiGenerated = data['ai_generated'] as Map<String, dynamic>?;
        if (aiGenerated?['is_ai_generated'] == true) {
          summary += 'Gambar kemungkinan dibuat oleh AI. ';
        }
        summary += 'Analisis manipulasi telah dilakukan.';
        break;
      case ContentType.video:
        final deepfake = data['deepfake_analysis'] as Map<String, dynamic>?;
        if (deepfake?['is_deepfake'] == true) {
          summary += 'Terdeteksi kemungkinan deepfake. ';
        }
        summary += 'Analisis keaslian video telah dilakukan.';
        break;
    }
    
    return summary;
  }
  
  /// Generate default findings
  static String _generateDefaultFindings(ContentType contentType, double score, Map<String, dynamic> data) {
    List<String> findings = [];
    
    switch (contentType) {
      case ContentType.text:
        final wordCount = data['word_count'] ?? 0;
        findings.add('• Panjang teks: $wordCount kata');
        
        final sentiment = data['sentiment'] as Map<String, dynamic>?;
        if (sentiment != null) {
          final label = sentiment['label'] ?? 'neutral';
          findings.add('• Sentimen: ${_getSentimentLabel(label)}');
        }
        
        final credScore = (data['credibility_score'] ?? 0.0) as num;
        if (credScore > 0.5) {
          findings.add('• Teks menyertakan referensi/sumber');
        } else {
          findings.add('• Tidak ada referensi sumber yang jelas');
        }
        break;
        
      case ContentType.url:
        final domain = data['domain'] ?? '';
        if (domain.isNotEmpty) {
          findings.add('• Domain: $domain');
        }
        final sslEnabled = data['ssl_enabled'] ?? false;
        findings.add('• Keamanan HTTPS: ${sslEnabled ? "Aktif ✓" : "Tidak Aktif ✗"}');
        
        final domainAge = data['domain_age'] as Map<String, dynamic>?;
        if (domainAge?['age_years'] != null) {
          findings.add('• Usia domain: ${domainAge!['age_years']} tahun');
        }
        break;
        
      case ContentType.image:
        final elaScore = (data['ela_score'] ?? data['ela']?['mean_ela'] ?? 0.5) as num;
        findings.add('• Skor ELA Analysis: ${(elaScore * 100).toStringAsFixed(0)}%');
        
        final manipScore = (data['manipulation_score'] ?? 0.3) as num;
        findings.add('• Skor Manipulasi: ${(manipScore * 100).toStringAsFixed(0)}%');
        
        final aiGen = data['ai_generated'] as Map<String, dynamic>?;
        if (aiGen != null) {
          final isAi = aiGen['is_ai_generated'] ?? false;
          findings.add('• Deteksi AI: ${isAi ? "Terdeteksi" : "Tidak Terdeteksi"}');
        }
        break;
        
      case ContentType.video:
        final deepfakeConf = (data['deepfake_analysis']?['confidence'] ?? 0.0) as num;
        findings.add('• Skor Deepfake: ${(deepfakeConf * 100).toStringAsFixed(0)}%');
        
        final audioAuth = (data['audio_analysis']?['score'] ?? 0.6) as num;
        findings.add('• Keaslian Audio: ${(audioAuth * 100).toStringAsFixed(0)}%');
        
        final visualCons = (data['visual_analysis']?['consistency_score'] ?? 0.7) as num;
        findings.add('• Konsistensi Visual: ${(visualCons * 100).toStringAsFixed(0)}%');
        break;
    }
    
    if (findings.isEmpty) {
      findings.add('• Analisis dasar telah dilakukan');
      findings.add('• Tidak ada temuan signifikan');
    }
    
    return findings.join('\n');
  }
  
  /// Generate default warnings
  static String _generateDefaultWarnings(ContentType contentType, double score, Map<String, dynamic> data) {
    List<String> warnings = [];
    
    if (score < 40) {
      warnings.add('⚠️ Skor kredibilitas rendah - perlu verifikasi mendalam');
    } else if (score < 60) {
      warnings.add('⚠️ Skor kredibilitas sedang - disarankan cross-check');
    }
    
    switch (contentType) {
      case ContentType.text:
        final hoaxScore = (data['hoax_score'] ?? 0.0) as num;
        if (hoaxScore > 0.5) {
          warnings.add('⚠️ Terdeteksi kata kunci yang sering digunakan dalam hoax');
        }
        final clickbaitScore = (data['clickbait_score'] ?? 0.0) as num;
        if (clickbaitScore > 0.5) {
          warnings.add('⚠️ Pola penulisan clickbait terdeteksi');
        }
        break;
        
      case ContentType.url:
        final sslEnabled = data['ssl_enabled'] ?? false;
        if (sslEnabled != true) {
          warnings.add('⚠️ Website tidak menggunakan HTTPS');
        }
        final patterns = data['suspicious_patterns'] as List? ?? [];
        if (patterns.isNotEmpty) {
          warnings.add('⚠️ Ditemukan ${patterns.length} pola mencurigakan');
        }
        break;
        
      case ContentType.image:
        final aiGen = data['ai_generated'] as Map<String, dynamic>?;
        if (aiGen?['is_ai_generated'] == true) {
          warnings.add('⚠️ Gambar kemungkinan dibuat oleh AI');
        }
        if (data['copy_move_detected'] == true) {
          warnings.add('⚠️ Terdeteksi kemungkinan copy-move forgery');
        }
        break;
        
      case ContentType.video:
        final deepfake = data['deepfake_analysis'] as Map<String, dynamic>?;
        if (deepfake?['is_deepfake'] == true) {
          warnings.add('⚠️ Terdeteksi kemungkinan deepfake');
        }
        break;
    }
    
    if (warnings.isEmpty) {
      warnings.add('✓ Tidak ada peringatan khusus');
    }
    
    return warnings.join('\n');
  }
  
  /// Generate default source info
  static String _generateDefaultSourceInfo(ContentType contentType, String source, Map<String, dynamic> data) {
    List<String> info = [];
    
    switch (contentType) {
      case ContentType.text:
        final wordCount = data['word_count'] ?? 0;
        info.add('📝 Jenis: Teks');
        info.add('📏 Jumlah kata: $wordCount');
        break;
        
      case ContentType.url:
        final domain = data['domain'] ?? '';
        info.add('🔗 Jenis: URL/Website');
        if (domain.isNotEmpty) {
          info.add('🌐 Domain: $domain');
        }
        break;
        
      case ContentType.image:
        final imgInfo = data['image_info'] as Map<String, dynamic>?;
        info.add('🖼️ Jenis: Gambar');
        if (imgInfo != null) {
          info.add('📐 Resolusi: ${imgInfo['width'] ?? 0}x${imgInfo['height'] ?? 0} pixels');
        }
        break;
        
      case ContentType.video:
        final vidInfo = data['video_info'] as Map<String, dynamic>?;
        info.add('🎬 Jenis: Video');
        if (vidInfo != null) {
          info.add('⏱️ Durasi: ${vidInfo['duration'] ?? 0} detik');
          info.add('📐 Resolusi: ${vidInfo['width'] ?? 0}x${vidInfo['height'] ?? 0}');
        }
        break;
    }
    
    if (source.isNotEmpty) {
      info.add('📍 Sumber: ${source.length > 50 ? '${source.substring(0, 50)}...' : source}');
    }
    
    return info.join('\n');
  }
  
  /// Helper untuk label sentiment
  static String _getSentimentLabel(String label) {
    switch (label.toLowerCase()) {
      case 'positive':
        return 'Positif 😊';
      case 'negative':
        return 'Negatif 😟';
      default:
        return 'Netral 😐';
    }
  }

  /// Konversi ke Map
  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'content_type': contentType.value,
      'score': score,
      'confidence': confidence,
      'status': status.label,
      'source': source,
      'ai_summary': aiSummary,
      'main_findings': mainFindings,
      'need_attention': needAttention,
      'about_source': aboutSource,
      'detailed_analysis': detailedAnalysis,
      'analysis_time': analysisTime,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
