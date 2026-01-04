
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:factify/models/challenge_models.dart';
import 'package:factify/utils/verysense_config.dart';

class ChallengeService {
  static final ChallengeService _instance = ChallengeService._internal();
  factory ChallengeService() => _instance;
  ChallengeService._internal();

  // Hardcoded Scenarios
  final List<ChallengeCase> _cases = [
    // TEKNOLOGI
    ChallengeCase(
      id: 'tech_1',
      topic: 'Teknologi',
      title: 'Konspirasi 5G & Kesehatan',
      imageUrl: 'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=800',
      background: 'Beredar pesan berantai di grup WhatsApp keluarga yang menyatakan bahwa menara 5G yang baru dibangun di kota Anda memancarkan radiasi yang dapat menurunkan sistem kekebalan tubuh dan menyebarkan virus digital. Pesan tersebut menyertakan foto menara dan diagram yang terlihat ilmiah tetapi tidak memiliki sumber jelas.',
      problem: 'Apakah klaim tentang 5G menyebarkan virus atau menurunkan imun itu benar? Bagaimana Anda memverifikasinya?',
      solution: 'Klaim ini adalah HOAKS (Teori Konspirasi). Fakta: 5G adalah gelombang radio non-ionizing yang tidak dapat merusak sel DNA atau menyebarkan virus biologis. Tidak ada bukti ilmiah yang menghubungkan 5G dengan penurunan imun. Pesan tersebut tidak memiliki sumber kredibel.',
    ),
    ChallengeCase(
      id: 'social_1',
      topic: 'Sosial',
      title: 'Bantuan Sosial Palsu',
      imageUrl: 'https://images.unsplash.com/photo-1556742049-0cfed4f7a07d?w=800',
      background: 'Sebuah tautan beredar di media sosial mengatasnamakan pemerintah, menjanjikan bantuan tunai Rp 5 juta bagi siapa saja yang mendaftar melalui website "bantuan-resmi-pemerintah.xyz". Website tersebut meminta NIK dan foto KTP.',
      problem: 'Analisis kredibilitas tautan tersebut. Apakah ini program resmi atau penipuan? Apa indikatornya?',
      solution: 'Ini adalah PHISHING/PENIPUAN. Indikator: 1) Domain tidak resmi (.xyz bukan .go.id). 2) Meminta data pribadi sensitif secara terbuka. 3) Tidak ada pengumuman di akun resmi pemerintah. Tujuannya adalah pencurian data (Identity Theft).',
    ),
     ChallengeCase(
      id: 'health_1',
      topic: 'Kesehatan',
      title: 'Obat Herbal Ajaib',
      imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=800',
      background: 'Video viral menunjukkan seseorang yang "sembuh total" dari diabetes kronis hanya dengan meminum air rebusan akar tertentu dalam 3 hari. Produk ini dijual online tanpa izin BPOM, tapi testimoninya ribuan.',
      problem: 'Secara medis, mungkinkah diabetes sembuh total dalam 3 hari? Bagaimana Anda menilai keamanan produk ini?',
      solution: 'Klaim ini HOAKS/KLAIM BERLEBIHAN. Diabetes adalah penyakit kronis yang tidak bisa "sembuh total" instan, hanya bisa dikontrol. Produk tanpa izin BPOM berisiko mengandung bahan berbahaya. Testimoni bisa dipalsukan. Diperlukan uji klinis, bukan sekadar testimoni.',
    ),
    ChallengeCase(
      id: 'politic_1',
      topic: 'Politik',
      title: 'Foto Pejabat Dimanipulasi',
      imageUrl: 'https://images.unsplash.com/photo-1529101091760-6149d4c81b22?w=800',
      background: 'Beredar foto seorang pejabat negara sedang minum alkohol di sebuah pesta mewah saat bencana alam terjadi. Foto tersebut memicu kemarahan publik. Namun, pencahayaan pada wajah pejabat terlihat berbeda dengan latar belakang.',
      problem: 'Lakukan analisis visual pada foto tersebut. Apakah foto ini asli atau rekayasa? Bagaimana langkah verifikasinya?',
      solution: 'Kemungkinan besar ini MANIPULASI DIGITAL (Editan). Indikator: Inkonsistensi pencahayaan (shadow/lighting), resolusi wajah berbeda dengan badan, atau tepi potongan yang kasar. Verifikasi: Gunakan Google Reverse Image Search untuk mencari foto asli.',
    ),
  ];

  ChallengeCase getRandomCase(List<String> topics) {
    // Filter cases based on selected topics
    // If topics is empty or select all, analyze all
    List<ChallengeCase> filtered = _cases;
    if (topics.isNotEmpty) {
      filtered = _cases.where((c) => topics.any((t) => t.toLowerCase() == c.topic.toLowerCase())).toList();
    }
    
    if (filtered.isEmpty) return _cases.first;
    
    // Return random
    return (filtered..shuffle()).first; 
  }

  Future<ChallengeResult> evaluateAnswer(ChallengeCase challengeCase, String answer, String sources) async {
    try {
      final url = Uri.parse('${VerysenseConfig.apiUrl}/challenge/evaluate');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'case': challengeCase.toJson(),
          'user_answer': answer,
          'user_sources': sources,
        }),
      );

      if (response.statusCode == 200) {
        return ChallengeResult.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to evaluate: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
