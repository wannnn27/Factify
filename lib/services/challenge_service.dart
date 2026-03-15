
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:factify/models/challenge_models.dart';
import 'package:factify/models/user_category.dart';
import 'package:factify/utils/verysense_config.dart';

class ChallengeService {
  static final ChallengeService _instance = ChallengeService._internal();
  factory ChallengeService() => _instance;
  ChallengeService._internal();

  // Hardcoded Scenarios dengan tingkat kesulitan
  final List<ChallengeCase> _cases = [
    // ============= LEVEL PEMULA (Untuk Pelajar) =============
    // Kasus sederhana dengan petunjuk jelas
    
    ChallengeCase(
      id: 'tech_pemula_1',
      topic: 'Teknologi',
      title: 'Konspirasi 5G & Kesehatan',
      imageUrl: 'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=800',
      background: 'Beredar pesan berantai di grup WhatsApp keluarga yang menyatakan bahwa menara 5G yang baru dibangun di kota Anda memancarkan radiasi yang dapat menurunkan sistem kekebalan tubuh dan menyebarkan virus digital. Pesan tersebut menyertakan foto menara dan diagram yang terlihat ilmiah tetapi tidak memiliki sumber jelas.',
      problem: 'Apakah klaim tentang 5G menyebarkan virus atau menurunkan imun itu benar? Bagaimana Anda memverifikasinya?',
      solution: 'Klaim ini adalah HOAKS (Teori Konspirasi). Fakta: 5G adalah gelombang radio non-ionizing yang tidak dapat merusak sel DNA atau menyebarkan virus biologis. Tidak ada bukti ilmiah yang menghubungkan 5G dengan penurunan imun. Pesan tersebut tidak memiliki sumber kredibel.',
      difficulty: ChallengeDifficulty.pemula,
    ),
    ChallengeCase(
      id: 'social_pemula_1',
      topic: 'Sosial',
      title: 'Bantuan Sosial Palsu',
      imageUrl: 'https://images.unsplash.com/photo-1556742049-0cfed4f7a07d?w=800',
      background: 'Sebuah tautan beredar di media sosial mengatasnamakan pemerintah, menjanjikan bantuan tunai Rp 5 juta bagi siapa saja yang mendaftar melalui website "bantuan-resmi-pemerintah.xyz". Website tersebut meminta NIK dan foto KTP.',
      problem: 'Analisis kredibilitas tautan tersebut. Apakah ini program resmi atau penipuan? Apa indikatornya?',
      solution: 'Ini adalah PHISHING/PENIPUAN. Indikator: 1) Domain tidak resmi (.xyz bukan .go.id). 2) Meminta data pribadi sensitif secara terbuka. 3) Tidak ada pengumuman di akun resmi pemerintah. Tujuannya adalah pencurian data (Identity Theft).',
      difficulty: ChallengeDifficulty.pemula,
    ),
    ChallengeCase(
      id: 'health_pemula_1',
      topic: 'Kesehatan',
      title: 'Obat Herbal Ajaib',
      imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=800',
      background: 'Video viral menunjukkan seseorang yang "sembuh total" dari diabetes kronis hanya dengan meminum air rebusan akar tertentu dalam 3 hari. Produk ini dijual online tanpa izin BPOM, tapi testimoninya ribuan.',
      problem: 'Secara medis, mungkinkah diabetes sembuh total dalam 3 hari? Bagaimana Anda menilai keamanan produk ini?',
      solution: 'Klaim ini HOAKS/KLAIM BERLEBIHAN. Diabetes adalah penyakit kronis yang tidak bisa "sembuh total" instan, hanya bisa dikontrol. Produk tanpa izin BPOM berisiko mengandung bahan berbahaya. Testimoni bisa dipalsukan. Diperlukan uji klinis, bukan sekadar testimoni.',
      difficulty: ChallengeDifficulty.pemula,
    ),
    ChallengeCase(
      id: 'edu_pemula_1',
      topic: 'Pendidikan',
      title: 'Beasiswa Gratis Palsu',
      imageUrl: 'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=800',
      background: 'Beredar broadcast di grup kelas tentang "Beasiswa Penuh ke Luar Negeri Tanpa Syarat" dari akun Instagram dengan 500 followers. Kamu hanya perlu transfer Rp 100.000 untuk "biaya administrasi".',
      problem: 'Apakah ini beasiswa asli atau penipuan? Apa tanda-tanda mencurigakannya?',
      solution: 'Ini PENIPUAN. Tanda-tanda: 1) Beasiswa resmi tidak pernah minta uang pendaftaran. 2) Akun dengan followers sedikit dan tidak terverifikasi. 3) Klaim "tanpa syarat" tidak realistis. 4) Beasiswa kredibel diumumkan via situs resmi universitas/.go.id/.org.',
      difficulty: ChallengeDifficulty.pemula,
    ),

    // ============= LEVEL MENENGAH (Untuk Mahasiswa) =============
    // Membutuhkan analisis lebih mendalam
    
    ChallengeCase(
      id: 'politic_menengah_1',
      topic: 'Politik',
      title: 'Foto Pejabat Dimanipulasi',
      imageUrl: 'https://images.unsplash.com/photo-1529101091760-6149d4c81b22?w=800',
      background: 'Beredar foto seorang pejabat negara sedang minum alkohol di sebuah pesta mewah saat bencana alam terjadi. Foto tersebut memicu kemarahan publik. Namun, pencahayaan pada wajah pejabat terlihat berbeda dengan latar belakang.',
      problem: 'Lakukan analisis visual pada foto tersebut. Apakah foto ini asli atau rekayasa? Bagaimana langkah verifikasinya?',
      solution: 'Kemungkinan besar ini MANIPULASI DIGITAL (Editan). Indikator: Inkonsistensi pencahayaan (shadow/lighting), resolusi wajah berbeda dengan badan, atau tepi potongan yang kasar. Verifikasi: Gunakan Google Reverse Image Search untuk mencari foto asli.',
      difficulty: ChallengeDifficulty.menengah,
    ),
    ChallengeCase(
      id: 'ekonomi_menengah_1',
      topic: 'Ekonomi',
      title: 'Investasi Crypto Cuan Pasti',
      imageUrl: 'https://images.unsplash.com/photo-1518546305927-5a555bb7020d?w=800',
      background: 'Seorang influencer dengan 1 juta followers mempromosikan "coin baru" dengan jaminan profit 500% dalam sebulan. Dia menunjukkan screenshot keuntungannya dan mengklaim ini "kesempatan terakhir sebelum harga naik".',
      problem: 'Evaluasi klaim investasi ini. Apa red flags yang perlu diperhatikan? Bagaimana cara memverifikasi legitimasi investasi crypto?',
      solution: 'Ini kemungkinan SCAM atau Pump & Dump. Red flags: 1) Jaminan profit tinggi adalah tanda klasik scam. 2) FOMO marketing ("kesempatan terakhir"). 3) Screenshot bisa dipalsukan. 4) Verifikasi: Cek di CoinMarketCap, whitepaper, tim developer, dan konsultasi OJK/regulator.',
      difficulty: ChallengeDifficulty.menengah,
    ),
    ChallengeCase(
      id: 'tech_menengah_1',
      topic: 'Teknologi',
      title: 'Kebocoran Data Nasional',
      imageUrl: 'https://images.unsplash.com/photo-1563986768609-322da13575f3?w=800',
      background: 'Akun anonim di Twitter mengklaim memiliki 270 juta data penduduk Indonesia dan menjualnya di dark web. Screenshot menunjukkan sample data dengan NIK, nama, dan alamat. Berita ini viral dan menimbulkan kepanikan.',
      problem: 'Bagaimana cara memverifikasi klaim kebocoran data ini? Apa langkah yang harus dilakukan masyarakat dan pemerintah?',
      solution: 'Verifikasi: 1) Cek apakah sample data valid atau dari database lama. 2) Tunggu konfirmasi dari BSSN/Kominfo. 3) Cek haveibeenpwned.com untuk alamat email. Langkah: Ganti password, aktifkan 2FA, waspada phishing. Pemerintah harus investigasi dan transparan.',
      difficulty: ChallengeDifficulty.menengah,
    ),
    ChallengeCase(
      id: 'social_menengah_1',
      topic: 'Sosial',
      title: 'Hoax Konflik SARA',
      imageUrl: 'https://images.unsplash.com/photo-1517048676732-d65bc937f952?w=800',
      background: 'Beredar video berdurasi 30 detik yang menunjukkan kerusuhan di sebuah daerah dengan caption "Telah terjadi pembakaran tempat ibadah oleh kelompok X". Video mendapat ribuan share dan komentar berisi hasutan.',
      problem: 'Bagaimana cara memverifikasi keaslian video ini? Apa dampak menyebarkan konten seperti ini tanpa verifikasi?',
      solution: 'Verifikasi: 1) Cek dengan reverse video search. 2) Cari berita dari media kredibel. 3) Perhatikan detail latar (cuaca, pakaian, bahasa). 4) Hubungi kepolisian/pihak terkait. Dampak penyebaran tanpa verifikasi: UU ITE tentang hoax dan SARA, memperkeruh situasi, memecah belah masyarakat.',
      difficulty: ChallengeDifficulty.menengah,
    ),

    // ============= LEVEL LANJUTAN (Untuk Pekerja/Profesional) =============
    // Kasus kompleks dengan nuansa halus
    
    ChallengeCase(
      id: 'politic_lanjutan_1',
      topic: 'Politik',
      title: 'Deepfake Pidato Presiden',
      imageUrl: 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=800',
      background: 'Video pidato presiden yang "bocor" menyatakan akan menaikkan pajak 200% beredar menjelang pemilu. Video terlihat sangat meyakinkan, namun ada gerakan bibir yang sedikit tidak sinkron di beberapa bagian.',
      problem: 'Analisis kemungkinan video ini adalah deepfake. Jelaskan metodologi verifikasi komprehensif untuk konten media sintetis tingkat tinggi.',
      solution: 'Analisis Deepfake: 1) Forensik video: cek metadata, artifak kompresi abnormal. 2) Lip-sync analysis dengan tool AI. 3) Konsistensi micro-expressions. 4) Cross-reference dengan agenda resmi presiden. 5) Cek rilis resmi dari istana/sekretariat negara. 6) Konsultasi ahli forensik digital.',
      difficulty: ChallengeDifficulty.lanjutan,
    ),
    ChallengeCase(
      id: 'ekonomi_lanjutan_1',
      topic: 'Ekonomi',
      title: 'Manipulasi Laporan Keuangan',
      imageUrl: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800',
      background: 'Sebuah perusahaan startup unicorn mengumumkan profitabilitas perdananya dengan laporan keuangan fantastis. Namun, seorang analis anonim memposting thread panjang yang mengklaim angka-angka tersebut dimanipulasi dengan teknik "channel stuffing" dan "round-tripping".',
      problem: 'Bagaimana Anda memverifikasi klaim manipulasi laporan keuangan ini? Jelaskan teknik analisis forensik akuntansi yang relevan.',
      solution: 'Verifikasi: 1) Bandingkan revenue growth vs industry benchmark. 2) Analisis rasio account receivable turnover. 3) Cek common-size analysis untuk anomali. 4) Review auditor independen reports. 5) Investigasi related-party transactions. 6) Benford Law analysis pada angka keuangan. 7) Konsultasi OJK dan CPA profesional.',
      difficulty: ChallengeDifficulty.lanjutan,
    ),
    ChallengeCase(
      id: 'health_lanjutan_1',
      topic: 'Kesehatan',
      title: 'Studi Vaksin Kontroversial',
      imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=800',
      background: 'Jurnal pre-print yang belum peer-reviewed mengklaim menemukan korelasi antara vaksin tertentu dengan efek samping serius. Paper ini banyak dikutip media dan influencer antivaxx. Para ahli mengatakan metodologinya cacat, tapi paper belum dicabut.',
      problem: 'Bagaimana mengevaluasi kredibilitas studi ilmiah yang kontroversial? Jelaskan framework untuk assessing scientific literature quality.',
      solution: 'Evaluasi: 1) Status: Pre-print belum peer-reviewed = belum tervalidasi. 2) Metodologi: Sample size, control group, randomization, blinding. 3) Conflict of interest declaration. 4) Korelasi ≠ Kausalitas. 5) Konsensus komunitas ilmiah vs 1 studi. 6) Impact factor jurnal jika publish. 7) Respons dari badan kesehatan (WHO, FDA, BPOM).',
      difficulty: ChallengeDifficulty.lanjutan,
    ),
    ChallengeCase(
      id: 'tech_lanjutan_1',
      topic: 'Teknologi',
      title: 'AI-Generated Disinformasi Terkoordinasi',
      imageUrl: 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=800',
      background: 'Peneliti menemukan jaringan 50.000 akun bot yang menyebarkan narasi politik tertentu menggunakan artikel yang ditulis AI. Artikel-artikel tersebut grammatically correct, memiliki "sumber" palsu, dan sudah diterjemahkan ke 15 bahasa termasuk Indonesia.',
      problem: 'Jelaskan framework komprehensif untuk mendeteksi dan melawan kampanye disinformasi terkoordinasi yang menggunakan AI generatif modern.',
      solution: 'Framework: 1) Network analysis untuk pola koordinasi (post timing, content similarity). 2) AI text detection tools (GPTZero, etc). 3) OSINT untuk identifikasi origin akun. 4) Fact-check "sumber" yang dikutip. 5) Kolaborasi platform (Twitter, Meta) untuk takedown. 6) Media literacy education. 7) Regulatory approach dan koordinasi lintas negara.',
      difficulty: ChallengeDifficulty.lanjutan,
    ),
  ];

  /// Mendapatkan kasus random berdasarkan topic saja (metode lama untuk backward compatibility)
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

  /// Mendapatkan kasus random berdasarkan topic DAN tingkat kesulitan user
  /// [topics] - list topik yang dipilih user
  /// [userCategory] - kategori user (pelajar/mahasiswa/pekerja)
  ChallengeCase getRandomCaseByDifficulty(List<String> topics, UserCategory userCategory) {
    final targetDifficulty = _getDifficultyForCategory(userCategory);
    
    // Filter berdasarkan topic dulu
    List<ChallengeCase> filtered = _cases;
    if (topics.isNotEmpty) {
      filtered = _cases.where((c) => topics.any((t) => t.toLowerCase() == c.topic.toLowerCase())).toList();
    }
    
    // Kemudian filter berdasarkan difficulty
    List<ChallengeCase> difficultyFiltered = filtered.where((c) => c.difficulty == targetDifficulty).toList();
    
    // Jika tidak ada yang match difficulty, fallback ke semua topic yang filtered
    if (difficultyFiltered.isEmpty) {
      difficultyFiltered = filtered;
    }
    
    if (difficultyFiltered.isEmpty) return _cases.first;
    
    // Return random
    return (difficultyFiltered..shuffle()).first;
  }

  /// Mapping UserCategory ke ChallengeDifficulty
  ChallengeDifficulty _getDifficultyForCategory(UserCategory category) {
    switch (category) {
      case UserCategory.pelajar:
        return ChallengeDifficulty.pemula;
      case UserCategory.mahasiswa:
        return ChallengeDifficulty.menengah;
      case UserCategory.pekerja:
        return ChallengeDifficulty.lanjutan;
    }
  }

  /// Mendapatkan semua kasus berdasarkan difficulty
  List<ChallengeCase> getCasesByDifficulty(ChallengeDifficulty difficulty) {
    return _cases.where((c) => c.difficulty == difficulty).toList();
  }

  /// Mendapatkan jumlah kasus per difficulty
  Map<ChallengeDifficulty, int> getCasesCount() {
    return {
      ChallengeDifficulty.pemula: _cases.where((c) => c.difficulty == ChallengeDifficulty.pemula).length,
      ChallengeDifficulty.menengah: _cases.where((c) => c.difficulty == ChallengeDifficulty.menengah).length,
      ChallengeDifficulty.lanjutan: _cases.where((c) => c.difficulty == ChallengeDifficulty.lanjutan).length,
    };
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
