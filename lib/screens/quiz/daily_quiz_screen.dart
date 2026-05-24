import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:factify/services/user_stats_service.dart';

class DailyQuizScreen extends StatefulWidget {
  const DailyQuizScreen({super.key});

  @override
  State<DailyQuizScreen> createState() => _DailyQuizScreenState();
}

class _DailyQuizScreenState extends State<DailyQuizScreen> with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  
  // Quiz state
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  int? _selectedAnswer;
  bool _hasAnsweredCurrent = false;
  bool _quizCompleted = false;
  bool _alreadyCompletedToday = false;
  
  List<Map<String, dynamic>> _todayQuestions = [];
  
  // Master question pool (30+ questions for variety)
  final List<Map<String, dynamic>> _allQuestions = [
    // Verifikasi & Fact-Checking
    {
      'question': 'Apa langkah PERTAMA dalam metode SIFT untuk verifikasi informasi?',
      'options': ['Investigate the source', 'Stop', 'Find better coverage', 'Trace the original'],
      'correct': 1,
      'explanation': 'STOP adalah langkah pertama - berhenti sejenak sebelum bereaksi atau membagikan informasi.',
      'category': 'Verifikasi',
    },
    {
      'question': 'Tool mana yang paling tepat untuk mengecek apakah sebuah gambar sudah pernah digunakan sebelumnya?',
      'options': ['Google Maps', 'Google Reverse Image Search', 'Google Translate', 'Google Calendar'],
      'correct': 1,
      'explanation': 'Google Reverse Image Search memungkinkan Anda mencari sumber asli dan penggunaan sebelumnya dari sebuah gambar.',
      'category': 'Verifikasi',
    },
    {
      'question': 'Situs fact-checking mana yang BUKAN dari Indonesia?',
      'options': ['cekfakta.com', 'turnbackhoax.id', 'snopes.com', 'liputan6.com/cek-fakta'],
      'correct': 2,
      'explanation': 'Snopes.com adalah situs fact-checking dari Amerika Serikat, sementara lainnya dari Indonesia.',
      'category': 'Verifikasi',
    },
    
    // Keamanan Digital
    {
      'question': 'Two-Factor Authentication (2FA) yang paling aman adalah...',
      'options': ['SMS OTP', 'App Authenticator', 'Email OTP', 'Security Questions'],
      'correct': 1,
      'explanation': 'App Authenticator seperti Google Authenticator menghasilkan kode lokal yang tidak bisa diintersep seperti SMS.',
      'category': 'Keamanan',
    },
    {
      'question': 'Berapa minimal karakter yang direkomendasikan untuk password yang aman?',
      'options': ['8 karakter', '12 karakter', '16 karakter', '6 karakter'],
      'correct': 2,
      'explanation': 'NIST merekomendasikan minimal 16 karakter untuk keamanan optimal. Panjang lebih penting dari kompleksitas.',
      'category': 'Keamanan',
    },
    {
      'question': 'Apa yang harus dilakukan saat menggunakan WiFi publik?',
      'options': ['Login ke bank online', 'Gunakan VPN', 'Share password WiFi', 'Matikan firewall'],
      'correct': 1,
      'explanation': 'VPN mengenkripsi koneksi Anda, melindungi data dari penyadapan di jaringan publik.',
      'category': 'Keamanan',
    },
    {
      'question': 'Password manager mana yang GRATIS dan open-source?',
      'options': ['1Password', 'Dashlane', 'Bitwarden', 'LastPass Premium'],
      'correct': 2,
      'explanation': 'Bitwarden adalah password manager gratis dan open-source yang sangat direkomendasikan.',
      'category': 'Keamanan',
    },
    
    // Hoaks & Disinformasi
    {
      'question': 'Menurut studi MIT, berita palsu menyebar berapa kali lebih cepat dari fakta di media sosial?',
      'options': ['2 kali', '4 kali', '6 kali', '10 kali'],
      'correct': 2,
      'explanation': 'Studi MIT di jurnal Science menemukan bahwa berita palsu menyebar 6 kali lebih cepat dari fakta.',
      'category': 'Hoaks',
    },
    {
      'question': 'Teknik manipulasi "Gish Gallop" adalah...',
      'options': ['Menggunakan gambar palsu', 'Membanjiri dengan banyak klaim', 'Menyamar sebagai ahli', 'Membuat judul clickbait'],
      'correct': 1,
      'explanation': 'Gish Gallop adalah teknik membanjiri dengan banyak klaim sehingga mustahil untuk dibantah satu per satu.',
      'category': 'Hoaks',
    },
    {
      'question': 'Apa yang dimaksud dengan "Confirmation Bias"?',
      'options': ['Selalu memverifikasi informasi', 'Cenderung mempercayai yang sesuai keyakinan', 'Meminta konfirmasi dari ahli', 'Mencari sumber kedua'],
      'correct': 1,
      'explanation': 'Confirmation bias adalah kecenderungan untuk mempercayai informasi yang sesuai dengan keyakinan yang sudah ada.',
      'category': 'Hoaks',
    },
    
    // Deepfake & AI
    {
      'question': 'Ciri visual deepfake yang paling mudah dikenali adalah...',
      'options': ['Resolusi video tinggi', 'Kedipan mata tidak natural', 'Suara yang jernih', 'Background yang blur'],
      'correct': 1,
      'explanation': 'Deepfake sering memiliki masalah dengan kedipan mata yang tidak natural atau terlalu jarang.',
      'category': 'AI',
    },
    {
      'question': 'Tool untuk mendeteksi video deepfake adalah...',
      'options': ['Adobe Photoshop', 'Microsoft Video Authenticator', 'VLC Player', 'YouTube Studio'],
      'correct': 1,
      'explanation': 'Microsoft Video Authenticator dirancang khusus untuk memberikan skor kepercayaan apakah video telah dimanipulasi.',
      'category': 'AI',
    },
    {
      'question': '"Liar\'s Dividend" dalam konteks deepfake berarti...',
      'options': ['Pembuat deepfake mendapat uang', 'Video asli bisa disangkal sebagai palsu', 'AI semakin pintar', 'Deepfake semakin realistis'],
      'correct': 1,
      'explanation': 'Liar\'s Dividend adalah fenomena dimana orang bisa menyangkal video asli dengan klaim "itu deepfake".',
      'category': 'AI',
    },
    
    // Privasi Digital
    {
      'question': 'Apa yang TIDAK boleh dishare di media sosial?',
      'options': ['Foto liburan', 'Hobi', 'Foto KTP/SIM', 'Rekomendasi buku'],
      'correct': 2,
      'explanation': 'Foto dokumen identitas seperti KTP/SIM tidak boleh dishare karena bisa disalahgunakan untuk penipuan.',
      'category': 'Privasi',
    },
    {
      'question': 'Website untuk mengecek apakah email Anda pernah bocor adalah...',
      'options': ['gmail.com', 'haveibeenpwned.com', 'facebook.com', 'twitter.com'],
      'correct': 1,
      'explanation': 'HaveIBeenPwned.com adalah layanan gratis untuk mengecek apakah email Anda terdampak data breach.',
      'category': 'Privasi',
    },
    {
      'question': 'Browser yang paling fokus pada privasi adalah...',
      'options': ['Google Chrome', 'Microsoft Edge', 'Brave/Firefox', 'Internet Explorer'],
      'correct': 2,
      'explanation': 'Brave dan Firefox memiliki fitur privasi bawaan yang lebih kuat, termasuk blocking tracker.',
      'category': 'Privasi',
    },
    
    // Media Literacy
    {
      'question': 'Ciri media online yang BUKAN kredibel adalah...',
      'options': ['Terdaftar di Dewan Pers', 'Ada halaman redaksi', 'Domain mirip media besar (kompas.com.co)', 'Mencantumkan sumber'],
      'correct': 2,
      'explanation': 'Domain tiruan seperti kompas.com.co adalah red flag - media palsu sering meniru domain media kredibel.',
      'category': 'Media',
    },
    {
      'question': 'Filter bubble menyebabkan...',
      'options': ['Melihat beragam perspektif', 'Hanya terpapar konten sesuai preferensi', 'Lebih kritis terhadap informasi', 'Algoritma lebih adil'],
      'correct': 1,
      'explanation': 'Filter bubble membuat kita hanya terpapar konten sesuai preferensi, menciptakan echo chamber.',
      'category': 'Media',
    },
    {
      'question': 'Cara keluar dari filter bubble adalah...',
      'options': ['Lebih banyak scroll', 'Follow akun dengan perspektif berbeda', 'Hanya baca berita viral', 'Percaya trending topic'],
      'correct': 1,
      'explanation': 'Sengaja follow akun/media dengan perspektif berbeda membantu mendapat pandangan lebih luas.',
      'category': 'Media',
    },
    
    // Bot & Akun Palsu
    {
      'question': 'Ciri akun bot di media sosial adalah...',
      'options': ['Foto profil personal', 'Posting dengan interval sangat teratur', 'Banyak interaksi natural', 'Bio yang detail'],
      'correct': 1,
      'explanation': 'Bot sering posting dengan interval mekanis yang sangat teratur, 24 jam tanpa jeda.',
      'category': 'Bot',
    },
    {
      'question': 'Tool untuk mendeteksi akun bot Twitter adalah...',
      'options': ['Instagram Insights', 'Botometer', 'Facebook Analytics', 'LinkedIn Sales'],
      'correct': 1,
      'explanation': 'Botometer (botometer.osome.iu.edu) menganalisis akun Twitter dan memberikan skor kemungkinan bot.',
      'category': 'Bot',
    },
    
    // Praktik Terbaik
    {
      'question': 'Sebelum share konten emosional, sebaiknya...',
      'options': ['Langsung forward', 'Tambah komentar sendiri', 'Tunggu dan verifikasi dulu', 'Share ke grup besar'],
      'correct': 2,
      'explanation': 'Konten emosional sering dirancang untuk bypass logika. Berhenti dan verifikasi sebelum menyebarkan.',
      'category': 'Praktik',
    },
    {
      'question': 'Aturan backup data 3-2-1 berarti...',
      'options': ['Backup 3x seminggu', '3 salinan, 2 media berbeda, 1 offsite', '3 folder, 2 drive, 1 cloud', 'Backup setiap 321 hari'],
      'correct': 1,
      'explanation': 'Aturan 3-2-1: 3 salinan data, di 2 media berbeda, dengan 1 backup di lokasi terpisah.',
      'category': 'Praktik',
    },
    {
      'question': 'Jika menerima pesan phishing, sebaiknya...',
      'options': ['Balas untuk memastikan', 'Klik link untuk cek', 'Hapus dan laporkan', 'Forward ke teman'],
      'correct': 2,
      'explanation': 'Jangan klik apapun atau balas. Hapus pesan dan laporkan sebagai spam/phishing.',
      'category': 'Praktik',
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    
    _loadTodayQuiz();
  }
  
  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }
  
  Future<void> _loadTodayQuiz() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    
    final lastQuizDate = prefs.getString('daily_quiz_date');
    final completedToday = lastQuizDate == todayKey;
    
    if (completedToday) {
      setState(() {
        _alreadyCompletedToday = true;
        _correctAnswers = prefs.getInt('daily_quiz_score') ?? 0;
      });
      return;
    }
    
    // Generate today's questions based on date seed
    final seed = today.year * 10000 + today.month * 100 + today.day;
    final random = Random(seed);
    
    // Shuffle and pick 5 questions
    final shuffled = List<Map<String, dynamic>>.from(_allQuestions);
    shuffled.shuffle(random);
    
    setState(() {
      _todayQuestions = shuffled.take(5).toList();
    });
  }
  
  void _selectAnswer(int index) {
    if (_hasAnsweredCurrent) return;
    
    HapticFeedback.mediumImpact();
    
    final isCorrect = index == _todayQuestions[_currentQuestionIndex]['correct'];
    
    setState(() {
      _selectedAnswer = index;
      _hasAnsweredCurrent = true;
      if (isCorrect) _correctAnswers++;
    });
  }
  
  void _nextQuestion() {
    if (_currentQuestionIndex < _todayQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _hasAnsweredCurrent = false;
      });
      _animController.reset();
      _animController.forward();
    } else {
      _completeQuiz();
    }
  }
  
  Future<void> _completeQuiz() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    
    await prefs.setString('daily_quiz_date', todayKey);
    await prefs.setInt('daily_quiz_score', _correctAnswers);
    
    // Track stats
    for (int i = 0; i < _correctAnswers; i++) {
      await userStats.answeredQuiz(true);
    }
    for (int i = 0; i < (5 - _correctAnswers); i++) {
      await userStats.answeredQuiz(false);
    }
    
    setState(() {
      _quizCompleted = true;
    });
    
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0F1E), Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: SafeArea(
          child: _alreadyCompletedToday
              ? _buildAlreadyCompleted()
              : _quizCompleted
                  ? _buildQuizCompleted()
                  : _buildQuizContent(),
        ),
      ),
    );
  }
  
  Widget _buildAlreadyCompleted() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildHeader(),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4ECDC4).withValues(alpha: 0.15),
                  const Color(0xFF4ECDC4).withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF4ECDC4).withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4ECDC4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 48),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Kuis Hari Ini Selesai! 🎉',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Skor kamu: $_correctAnswers/5',
                  style: const TextStyle(
                    color: Color(0xFF4ECDC4),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kembali besok untuk kuis baru!',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ECDC4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Kembali ke Home', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuizCompleted() {
    final percentage = (_correctAnswers / 5 * 100).round();
    final xpEarned = _correctAnswers * 10;
    
    String message;
    Color accentColor;
    IconData icon;
    
    if (_correctAnswers == 5) {
      message = 'Sempurna! 🌟';
      accentColor = const Color(0xFFFFD93D);
      icon = Icons.emoji_events;
    } else if (_correctAnswers >= 4) {
      message = 'Luar Biasa! 🎉';
      accentColor = const Color(0xFF4ECDC4);
      icon = Icons.star;
    } else if (_correctAnswers >= 3) {
      message = 'Bagus! 👍';
      accentColor = const Color(0xFF5B9BD5);
      icon = Icons.thumb_up;
    } else {
      message = 'Terus Belajar! 💪';
      accentColor = const Color(0xFF9B59B6);
      icon = Icons.school;
    }
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildHeader(),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor.withValues(alpha: 0.15),
                  accentColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: accentColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [accentColor, accentColor.withValues(alpha: 0.7)]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 48),
                ),
                const SizedBox(height: 24),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildResultStat('Benar', '$_correctAnswers/5', accentColor),
                    const SizedBox(width: 24),
                    _buildResultStat('Akurasi', '$percentage%', accentColor),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFFD93D), Color(0xFFF39C12)]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '+$xpEarned XP',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Kembali ke Home', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildResultStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuizContent() {
    if (_todayQuestions.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF4ECDC4)));
    }
    
    final question = _todayQuestions[_currentQuestionIndex];
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            
            // Progress bar
            _buildProgressBar(),
            const SizedBox(height: 24),
            
            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF6C5CE7).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                question['category'] ?? 'Umum',
                style: const TextStyle(
                  color: Color(0xFF6C5CE7),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Question
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      question['question'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    
                    // Options
                    ...List.generate(
                      (question['options'] as List).length,
                      (index) => _buildOption(index, question['options'][index], question['correct']),
                    ),
                    
                    // Explanation
                    if (_hasAnsweredCurrent) ...[
                      const SizedBox(height: 20),
                      _buildExplanation(question),
                    ],
                  ],
                ),
              ),
            ),
            
            // Next button
            if (_hasAnsweredCurrent)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ECDC4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _currentQuestionIndex < 4 ? 'Pertanyaan Berikutnya' : 'Lihat Hasil',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const Expanded(
          child: Text(
            'Kuis Harian',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD93D).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.stars, color: Color(0xFFFFD93D), size: 16),
              const SizedBox(width: 4),
              Text(
                '${_correctAnswers * 10} XP',
                style: const TextStyle(
                  color: Color(0xFFFFD93D),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildProgressBar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Soal ${_currentQuestionIndex + 1} dari 5',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
            Text(
              '$_correctAnswers benar',
              style: const TextStyle(
                color: Color(0xFF4ECDC4),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / 5,
          backgroundColor: Colors.white.withValues(alpha: 0.1),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4ECDC4)),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
  
  Widget _buildOption(int index, String text, int correctIndex) {
    final isSelected = _selectedAnswer == index;
    final isCorrect = correctIndex == index;
    
    Color borderColor = Colors.white.withValues(alpha: 0.2);
    Color bgColor = Colors.white.withValues(alpha: 0.05);
    IconData? trailingIcon;
    
    if (_hasAnsweredCurrent) {
      if (isCorrect) {
        borderColor = const Color(0xFF4ECDC4);
        bgColor = const Color(0xFF4ECDC4).withValues(alpha: 0.15);
        trailingIcon = Icons.check_circle;
      } else if (isSelected && !isCorrect) {
        borderColor = const Color(0xFFFF6B6B);
        bgColor = const Color(0xFFFF6B6B).withValues(alpha: 0.15);
        trailingIcon = Icons.cancel;
      }
    } else if (isSelected) {
      borderColor = const Color(0xFF6C5CE7);
      bgColor = const Color(0xFF6C5CE7).withValues(alpha: 0.15);
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _selectAnswer(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? borderColor : Colors.transparent,
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index), // A, B, C, D
                    style: TextStyle(
                      color: isSelected ? Colors.white : borderColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 15,
                  ),
                ),
              ),
              if (trailingIcon != null)
                Icon(trailingIcon, color: borderColor, size: 24),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildExplanation(Map<String, dynamic> question) {
    final isCorrect = _selectedAnswer == question['correct'];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isCorrect ? const Color(0xFF4ECDC4) : const Color(0xFFFF6B6B)).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isCorrect ? const Color(0xFF4ECDC4) : const Color(0xFFFF6B6B)).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.info,
            color: isCorrect ? const Color(0xFF4ECDC4) : const Color(0xFFFF6B6B),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect ? 'Benar! 🎉' : 'Jawaban yang tepat: ${question['options'][question['correct']]}',
                  style: TextStyle(
                    color: isCorrect ? const Color(0xFF4ECDC4) : const Color(0xFFFF6B6B),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  question['explanation'],
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
