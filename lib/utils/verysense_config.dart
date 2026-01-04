
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Konfigurasi untuk Verysense
class VerysenseConfig {
  /// Base URL untuk API Verysense
  static String get apiUrl {
    return dotenv.env['VERYSENSE_API_URL'] ?? 'https://arwnsyh-factify-models.hf.space';
  }

  /// Mode debug
  static bool get isDebug => kDebugMode;

  /// Timeout untuk request (dalam detik)
  static int get requestTimeout => 60;

  /// Timeout untuk video analysis (dalam detik)
  static int get videoAnalysisTimeout => 300;

  /// Maximum file size untuk upload (dalam MB)
  static int get maxFileSizeMB => 50;

  /// Log debug message
  static void log(String message) {
    if (isDebug) {
      debugPrint('[Verysense] $message');
    }
  }

  /// Log error message
  static void logError(String message, [Object? error]) {
    debugPrint('[Verysense ERROR] $message${error != null ? ': $error' : ''}');
  }
}

/// Helper untuk format hasil verifikasi
class VerysenseFormatter {
  /// Format skor ke string dengan persentase
  static String formatScore(double score) {
    return '${score.round()}%';
  }

  /// Format waktu analisis
  static String formatAnalysisTime(double seconds) {
    if (seconds < 1) {
      return '${(seconds * 1000).round()}ms';
    } else if (seconds < 60) {
      return '${seconds.toStringAsFixed(1)}s';
    } else {
      final minutes = (seconds / 60).floor();
      final remainingSeconds = (seconds % 60).round();
      return '${minutes}m ${remainingSeconds}s';
    }
  }

  /// Get warna berdasarkan skor
  static int getScoreColorValue(double score, {bool inverse = false}) {
    if (inverse) {
      // Lower score = better (e.g., for hoax score)
      if (score <= 30) return 0xFF4ECDC4; // Green
      if (score <= 60) return 0xFFFFD93D; // Yellow
      return 0xFFFF6B6B; // Red
    } else {
      // Higher score = better (e.g., for credibility)
      if (score >= 70) return 0xFF4ECDC4; // Green
      if (score >= 40) return 0xFFFFD93D; // Yellow
      return 0xFFFF6B6B; // Red
    }
  }

  /// Get label status berdasarkan skor
  static String getStatusLabel(double score) {
    if (score >= 80) return 'Kredibel';
    if (score >= 60) return 'Cukup Kredibel';
    if (score >= 40) return 'Perlu Perhatian';
    return 'Tidak Kredibel';
  }

  /// Get emoji untuk status
  static String getStatusEmoji(double score) {
    if (score >= 80) return '✅';
    if (score >= 60) return '🟢';
    if (score >= 40) return '⚠️';
    return '❌';
  }
}

/// Validator untuk input verifikasi
class VerysenseValidator {
  /// Validasi URL
  static String? validateUrl(String? url) {
    if (url == null || url.trim().isEmpty) {
      return 'URL tidak boleh kosong';
    }

    final trimmed = url.trim();
    
    // Basic URL pattern check
    final urlPattern = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
    );

    if (!urlPattern.hasMatch(trimmed)) {
      return 'Format URL tidak valid';
    }

    return null;
  }

  /// Validasi teks
  static String? validateText(String? text, {int minLength = 10, int maxLength = 50000}) {
    if (text == null || text.trim().isEmpty) {
      return 'Teks tidak boleh kosong';
    }

    final trimmed = text.trim();

    if (trimmed.length < minLength) {
      return 'Teks terlalu pendek (minimal $minLength karakter)';
    }

    if (trimmed.length > maxLength) {
      return 'Teks terlalu panjang (maksimal $maxLength karakter)';
    }

    return null;
  }

  /// Validasi file size
  static String? validateFileSize(int bytes, {int maxMB = 50}) {
    final maxBytes = maxMB * 1024 * 1024;
    if (bytes > maxBytes) {
      return 'File terlalu besar (maksimal ${maxMB}MB)';
    }
    return null;
  }
}
