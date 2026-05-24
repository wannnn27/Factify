
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/verification_result.dart';
import '../utils/verysense_config.dart';

/// Exception khusus untuk error Verysense
class VerysenseException implements Exception {
  final String message;
  final int? statusCode;
  final String? details;

  VerysenseException(this.message, {this.statusCode, this.details});

  @override
  String toString() => 'VerysenseException: $message';
}

/// Service untuk berkomunikasi dengan Verysense ML API
class VerysenseService {
  // Base URL - delegated to central config to avoid duplication
  static String get _baseUrl {
    final url = VerysenseConfig.apiUrl;
    debugPrint('[VerysenseService] Base URL: $url');
    return url;
  }

  // Headers untuk request
  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Timeout settings
  static const Duration _timeout = Duration(seconds: 60);

  /// Cek koneksi ke API
  static Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(_timeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('[VerysenseService] Health check: ${data['status']}');
        return data['status'] == 'healthy';
      }
      return false;
    } catch (e) {
      debugPrint('[VerysenseService] Health check failed: $e');
      return false;
    }
  }

  /// Get status API dan analyzers
  static Future<Map<String, dynamic>> getStatus() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/status'))
          .timeout(_timeout);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw VerysenseException('Failed to get status', statusCode: response.statusCode);
    } catch (e) {
      debugPrint('[VerysenseService] Get status failed: $e');
      rethrow;
    }
  }

  /// Verifikasi teks
  static Future<VerificationResult> verifyText(String text) async {
    if (text.trim().isEmpty) {
      throw VerysenseException('Text cannot be empty');
    }

    try {
      debugPrint('[VerysenseService] Verifying text (${text.length} chars)...');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/verify/text'),
        headers: _jsonHeaders,
        body: json.encode({'text': text}),
      ).timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      debugPrint('[VerysenseService] Verify text error: $e');
      rethrow;
    }
  }

  /// Verifikasi URL
  static Future<VerificationResult> verifyUrl(String url) async {
    if (url.trim().isEmpty) {
      throw VerysenseException('URL cannot be empty');
    }

    // Add https:// if not present
    String processedUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      processedUrl = 'https://$url';
    }

    try {
      debugPrint('[VerysenseService] Verifying URL: $processedUrl');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/verify/url'),
        headers: _jsonHeaders,
        body: json.encode({'url': processedUrl}),
      ).timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      debugPrint('[VerysenseService] Verify URL error: $e');
      rethrow;
    }
  }

  /// Verifikasi gambar dari file (mobile only - use verifyImageBytes for web)
  static Future<VerificationResult> verifyImageFile(dynamic imageFile) async {
    try {
      debugPrint('[VerysenseService] Verifying image file');
      
      final bytes = await imageFile.readAsBytes() as Uint8List;
      final path = imageFile.path as String;
      return verifyImageBytes(bytes, path.split(RegExp(r'[/\\]')).last);
    } catch (e) {
      debugPrint('[VerysenseService] Verify image file error: $e');
      rethrow;
    }
  }

  /// Verifikasi gambar dari bytes (multipart upload)
  static Future<VerificationResult> verifyImageBytes(Uint8List bytes, String filename) async {
    try {
      debugPrint('[VerysenseService] Verifying image bytes (${bytes.length} bytes)');
      
      final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/verify/image'));
      
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: filename,
      ));

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      debugPrint('[VerysenseService] Verify image bytes error: $e');
      rethrow;
    }
  }

  /// Verifikasi gambar dari base64
  static Future<VerificationResult> verifyImageBase64(String base64Image) async {
    try {
      debugPrint('[VerysenseService] Verifying image from base64');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/verify/image'),
        headers: _jsonHeaders,
        body: json.encode({'image_base64': base64Image}),
      ).timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      debugPrint('[VerysenseService] Verify image base64 error: $e');
      rethrow;
    }
  }

  /// Verifikasi gambar dari URL
  static Future<VerificationResult> verifyImageUrl(String imageUrl) async {
    try {
      debugPrint('[VerysenseService] Verifying image from URL: $imageUrl');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/verify/image'),
        headers: _jsonHeaders,
        body: json.encode({'image_url': imageUrl}),
      ).timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      debugPrint('[VerysenseService] Verify image URL error: $e');
      rethrow;
    }
  }

  /// Verifikasi video dari file (mobile only - use verifyVideoBytes for web)
  static Future<VerificationResult> verifyVideoFile(dynamic videoFile) async {
    try {
      debugPrint('[VerysenseService] Verifying video file');
      
      final path = videoFile.path as String;
      final bytes = await videoFile.readAsBytes() as Uint8List;
      
      return verifyVideoBytes(bytes, path.split(RegExp(r'[/\\]')).last);
    } catch (e) {
      debugPrint('[VerysenseService] Verify video file error: $e');
      rethrow;
    }
  }

  /// Verifikasi video dari bytes (multipart upload, untuk web & mobile)
  static Future<VerificationResult> verifyVideoBytes(Uint8List bytes, String filename) async {
    try {
      debugPrint('[VerysenseService] Verifying video bytes (${bytes.length} bytes)');
      
      final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/verify/video'));
      
      request.files.add(http.MultipartFile.fromBytes(
        'video',
        bytes,
        filename: filename,
      ));

      final streamedResponse = await request.send().timeout(const Duration(minutes: 5));
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      debugPrint('[VerysenseService] Verify video bytes error: $e');
      rethrow;
    }
  }

  /// Verifikasi video dari URL
  static Future<VerificationResult> verifyVideoUrl(String videoUrl) async {
    try {
      debugPrint('[VerysenseService] Verifying video from URL: $videoUrl');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/verify/video'),
        headers: _jsonHeaders,
        body: json.encode({'video_url': videoUrl}),
      ).timeout(const Duration(minutes: 5));

      return _handleResponse(response);
    } catch (e) {
      debugPrint('[VerysenseService] Verify video URL error: $e');
      rethrow;
    }
  }

  /// Auto-detect content type dan verifikasi
  static Future<VerificationResult> verifyAuto({
    required ContentType contentType,
    String? content,
    String? contentBase64,
    String? contentUrl,
  }) async {
    try {
      debugPrint('[VerysenseService] Auto-verify: $contentType');
      
      final body = <String, dynamic>{
        'content_type': contentType.value,
      };

      if (content != null) body['content'] = content;
      if (contentBase64 != null) body['content_base64'] = contentBase64;
      if (contentUrl != null) body['content_url'] = contentUrl;

      final response = await http.post(
        Uri.parse('$_baseUrl/verify'),
        headers: _jsonHeaders,
        body: json.encode(body),
      ).timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      debugPrint('[VerysenseService] Auto-verify error: $e');
      rethrow;
    }
  }

  /// Handle response dari API
  static VerificationResult _handleResponse(http.Response response) {
    debugPrint('[VerysenseService] Response status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      try {
        final body = utf8.decode(response.bodyBytes);
        if (body.trim().isEmpty) {
          throw VerysenseException(
            'Empty response from server',
            details: 'Response body is empty. Video verification may have timed out or failed on server.',
          );
        }
        final data = json.decode(body) as Map<String, dynamic>?;
        if (data == null) {
          throw VerysenseException('Invalid response format', details: 'Expected JSON object');
        }
        debugPrint('[VerysenseService] Response keys: ${data.keys.join(', ')}');
        return VerificationResult.fromJson(data);
      } catch (e, stack) {
        debugPrint('[VerysenseService] Parse error: $e');
        debugPrint('[VerysenseService] Stack: $stack');
        final details = e is VerysenseException ? e.details : e.toString();
        throw VerysenseException('Failed to parse response', details: details);
      }
    } else {
      // Try to get error message from response
      String errorMessage = 'Request failed';
      try {
        final errorData = json.decode(response.body);
        errorMessage = errorData['error'] ?? errorMessage;
      } catch (_) {}
      
      throw VerysenseException(
        errorMessage,
        statusCode: response.statusCode,
      );
    }
  }

  /// Convert File gambar ke base64 (mobile only)
  static Future<String> imageFileToBase64(dynamic imageFile) async {
    final bytes = await imageFile.readAsBytes() as Uint8List;
    final base64Data = base64Encode(bytes);
    
    // Detect mime type from extension
    final path = imageFile.path as String;
    final extension = path.split('.').last.toLowerCase();
    String mimeType = 'image/jpeg';
    switch (extension) {
      case 'png':
        mimeType = 'image/png';
        break;
      case 'gif':
        mimeType = 'image/gif';
        break;
      case 'webp':
        mimeType = 'image/webp';
        break;
    }
    
    return 'data:$mimeType;base64,$base64Data';
  }
}
