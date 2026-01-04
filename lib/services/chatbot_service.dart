import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:factify/models/chat_message.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatbotService {
  // Backend URL - same as Verysense
  static String get _baseUrl {
    return dotenv.env['VERYSENSE_API_URL'] ?? 'https://arwnsyh-factify-models.hf.space';
  }

  static const _headers = {'Content-Type': 'application/json'};

  Future<String> getResponse(String userMessage, List<ChatMessage> context) async {
    try {
      debugPrint("[ChatbotService] Sending message to backend: $userMessage");
      
      // Build history from context
      final history = context
          .where((msg) => !msg.isTyping)
          .map((msg) => {
                'role': msg.isUser ? 'user' : 'model',
                'text': msg.text,
              })
          .toList();

      final body = {
        'message': userMessage,
        'history': history,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/chat'),
        headers: _headers,
        body: json.encode(body),
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw Exception('Request timeout'),
      );

      debugPrint("[ChatbotService] Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        
        if (data['status'] == 'success' && data['response'] != null) {
          return data['response'].toString().trim();
        } else if (data['error'] != null) {
          return "Error: ${data['error']}";
        }
        
        return "Maaf, aku tidak bisa memberikan jawaban untuk itu. 🤔";
      } else {
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        debugPrint("[ChatbotService] Error: $errorData");
        
        if (response.statusCode == 429) {
          return "Terlalu banyak permintaan! Tunggu beberapa saat lalu coba lagi ya.";
        } else if (response.statusCode == 500) {
          final errorMsg = errorData['error'] ?? 'Server error';
          return "Ada masalah di server: $errorMsg";
        }
        
        return "Ada sedikit masalah teknis (Kode: ${response.statusCode}). Coba lagi ya!";
      }
    } catch (e, s) {
      debugPrint("[ChatbotService] Error: $e");
      debugPrint("[ChatbotService] Stacktrace: $s");
      
      if (e.toString().contains('timeout')) {
        return "Koneksi timeout! Server membutuhkan waktu lebih lama. Coba lagi ya!";
      }
      
      return "Sepertinya ada gangguan koneksi. Pastikan internet kamu stabil dan coba lagi! 📶";
    }
  }
}