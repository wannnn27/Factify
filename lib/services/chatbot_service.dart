import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:factify/models/chat_message.dart';
import 'package:flutter/foundation.dart';

class ChatbotService {
  // Ambil API Key dari environment variables
  static String get _apiKey {
    final key = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (key.isEmpty) {
      debugPrint("WARNING: GEMINI_API_KEY is empty!");
    } else {
      debugPrint("API Key loaded (length: ${key.length})");
    }
    return key;
  }
  
  static const String _model = 'gemini-1.5-pro-latest';

  static Uri get _uri => Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey');

  static const String _systemPrompt = '''
  Kamu adalah Facti, asisten digital yang ramah, berpengetahuan luas, dan sangat antusias.
  Misi utama kamu adalah membuat literasi digital, keamanan online, dan cara mengenali hoaks/informasi palsu menjadi topik yang menarik dan mudah dipahami oleh siapa saja, terutama anak muda di Indonesia.
  
  Gaya bahasamu harus:
  - **Bahasa Indonesia yang Santai & Modern:** Gunakan sapaan seperti "kamu", "bro", "sis", dan istilah kekinian yang relevan.
  - **Informatif tapi Tidak Kaku:** Sajikan fakta dan data dengan cara yang ringan, seolah sedang mengobrol dengan teman.
  - **Penuh Emoji & Ekspresif:** Gunakan emoji secara kreatif untuk menekankan poin, menunjukkan emosi, dan membuat teks lebih hidup! 🎉💡🤔
  - **Struktur yang Mudah Dibaca:** Selalu gunakan poin-poin (bullet points) atau penomoran untuk menjelaskan langkah-langkah atau daftar ide.
  - **Proaktif dan Mendorong Rasa Ingin Tahu:** Jangan hanya menjawab pertanyaan. Berikan pertanyaan lanjutan, fakta menarik, atau ajakan untuk mencoba sesuatu yang berhubungan dengan topik.

  Aturan Penting:
  - **Fokus Utama:** Prioritaskan jawaban seputar literasi digital, privasi data, jejak digital, keamanan siber, mengenali hoaks, etika online, dan topik terkait.
  - **Jika Di Luar Topik:** Jawab dengan sopan dan kreatif untuk mengaitkannya kembali ke dunia digital.
  - **Selalu Positif dan Membantu:** Ciptakan suasana yang positif.
  ''';

  static const _headers = {'Content-Type': 'application/json'};

  Future<String> getResponse(String userMessage, List<ChatMessage> context) async {
    // Validasi API Key
    if (_apiKey.isEmpty) {
      return "ERROR: GEMINI_API_KEY tidak ditemukan!\n\n"
          "Pastikan:\n"
          "1. File .env ada di root project\n"
          "2. Isi file: GEMINI_API_KEY=AIzaSy...\n"
          "3. Sudah flutter pub get\n"
          "4. Restart aplikasi";
    }

    try {
      final history = <Map<String, dynamic>>[
        {
          'role': 'user',
          'parts': [{'text': _systemPrompt}]
        },
        {
          'role': 'model',
          'parts': [{'text': "Siap! Aku Facti, teman digitalmu. Tanya apa saja soal dunia online, aku bantu jelaskan!"}]
        },
        ...context.where((msg) => !msg.isTyping).map((msg) => {
              'role': msg.isUser ? 'user' : 'model',
              'parts': [{'text': msg.text}]
            })
      ];

      final body = {
        'contents': [
          ...history,
          {
            'role': 'user',
            'parts': [{'text': userMessage}]
          }
        ],
        "safetySettings": [
          {"category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_ONLY_HIGH"},
          {"category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_ONLY_HIGH"}
        ]
      };

      debugPrint("Sending request to Gemini API...");
      
      final response = await http.post(
        _uri,
        headers: _headers,
        body: json.encode(body),
      );

      debugPrint("Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(utf8.decode(response.bodyBytes));
        
        if (decodedResponse.containsKey('candidates') &&
            decodedResponse['candidates'].isNotEmpty &&
            decodedResponse['candidates'][0].containsKey('content') &&
            decodedResponse['candidates'][0]['content'].containsKey('parts') &&
            decodedResponse['candidates'][0]['content']['parts'].isNotEmpty) {
              
          return decodedResponse['candidates'][0]['content']['parts'][0]['text'].trim();
        } else {
          return "Maaf, aku tidak bisa memberikan jawaban untuk itu. Mungkin kita bisa bahas topik lain seputar keamanan digital? 🤔";
        }
      } else {
        final errorBody = json.decode(utf8.decode(response.bodyBytes));
        debugPrint("HTTP Error ${response.statusCode}: $errorBody");
        
        if (response.statusCode == 400) {
          return "API Key tidak valid atau quota habis.\nCek API key di Google AI Studio: https://aistudio.google.com/apikey";
        }
        
        return "Aduh, ada sedikit masalah teknis nih (Kode: ${response.statusCode}). Coba tanya lagi beberapa saat ya.";
      }
    } catch (e, s) {
      debugPrint("Error calling Gemini API: $e");
      debugPrint("Stacktrace: $s");
      return "Duh, kayaknya ada gangguan koneksi ke server AI-ku nih 🛰️. Pastiin internet kamu stabil dan coba beberapa saat lagi ya!";
    }
  }
}