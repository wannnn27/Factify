import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:factify/models/challenge_models.dart';
import 'package:factify/models/user_category.dart';
import 'package:factify/services/challenge_service.dart';
import 'package:factify/services/auth_service.dart';
import 'package:factify/services/user_stats_service.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  // Selected categories
  Set<String> selectedCategories = {};

  // User category from Firestore
  UserCategory _userCategory = UserCategory.pelajar; // Default
  bool _isLoadingCategory = true;

  @override
  void initState() {
    super.initState();
    _loadUserCategory();
  }

  Future<void> _loadUserCategory() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await AuthService().getUserData(user.uid);
        if (userData != null && userData['userCategory'] != null) {
          setState(() {
            _userCategory = UserCategoryExtension.fromFirestoreValue(
              userData['userCategory'],
            );
            _isLoadingCategory = false;
          });
          return;
        }
      }
    } catch (e) {
      print('Error loading user category: $e');
    }
    setState(() {
      _isLoadingCategory = false;
    });
  }

  final List<Map<String, dynamic>> categories = [
    {
      'id': 'teknologi',
      'title': 'Teknologi',
      'icon': Icons.computer,
      'description':
          'Hoaks seputar AI, gadget, keamanan digital, dan teknologi terbaru.',
    },
    {
      'id': 'pendidikan',
      'title': 'Pendidikan',
      'icon': Icons.school,
      'description':
          'Isu fakta dan misinformasi di dunia sekolah, kampus, dan beasiswa.',
    },
    {
      'id': 'sosial',
      'title': 'Sosial',
      'icon': Icons.people,
      'description':
          'Rumor, berita viral, dan isu sosial yang sering disalahpahami.',
    },
    {
      'id': 'ekonomi',
      'title': 'Ekonomi',
      'icon': Icons.trending_up,
      'description': 'Hoaks investasi, keuangan, dan bisnis yang menyesatkan.',
    },
    {
      'id': 'kesehatan',
      'title': 'Kesehatan',
      'icon': Icons.local_hospital,
      'description':
          'Mitos kesehatan, obat ajaib, dan informasi medis yang salah.',
    },
    {
      'id': 'politik',
      'title': 'Politik',
      'icon': Icons.policy,
      'description':
          'Disinformasi pemilu, kebijakan publik, dan tokoh politik.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E232C),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            _buildHeader(),

            // CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TITLE
                    const Text(
                      "Pilih Tema Challenge",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // CATEGORY GRID
                    _buildCategoryGrid(),

                    const SizedBox(height: 24),

                    // START BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selectedCategories.isEmpty
                            ? null
                            : () => _startChallenge(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C9A7),
                          disabledBackgroundColor: const Color(0xFF2B3039),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          selectedCategories.isEmpty
                              ? "Pilih minimal 1 tema"
                              : "Mulai Challenge",
                          style: TextStyle(
                            color: selectedCategories.isEmpty
                                ? Colors.grey[600]
                                : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Spacer(),
              const Text(
                "Factify",
                style: TextStyle(
                  color: Color(0xFF00C9A7),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Selamat Datang di Factify Challenge!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Uji kemampuanmu dalam membedakan fakta dengan hoaks sekarang! AI akan menilai ketajaman analisis kamu.",
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // User Level Badge
          _buildUserLevelBadge(),
        ],
      ),
    );
  }

  Widget _buildUserLevelBadge() {
    if (_isLoadingCategory) {
      return const SizedBox(
        height: 32,
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF00C9A7),
            ),
          ),
        ),
      );
    }

    Color badgeColor;
    String levelText;
    IconData levelIcon;

    switch (_userCategory) {
      case UserCategory.pelajar:
        badgeColor = const Color(0xFF4CAF50);
        levelText = 'Level Pemula';
        levelIcon = Icons.school;
        break;
      case UserCategory.mahasiswa:
        badgeColor = const Color(0xFFFF9800);
        levelText = 'Level Menengah';
        levelIcon = Icons.account_balance;
        break;
      case UserCategory.pekerja:
        badgeColor = const Color(0xFFE91E63);
        levelText = 'Level Lanjutan';
        levelIcon = Icons.work;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(levelIcon, size: 16, color: badgeColor),
          const SizedBox(width: 8),
          Text(
            levelText,
            style: TextStyle(
              color: badgeColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '(${_userCategory.displayName})',
            style: TextStyle(color: badgeColor.withValues(alpha: 0.8), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = selectedCategories.contains(category['id']);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedCategories.remove(category['id']);
              } else {
                selectedCategories.add(category['id']);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2B3039),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF00C9A7)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      category['icon'],
                      color: const Color(0xFF00C9A7),
                      size: 24,
                    ),
                    const Spacer(),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF00C9A7),
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  category['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    category['description'],
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 11,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _startChallenge(BuildContext context) {
    // Get random case based on user category for appropriate difficulty
    final challengeCase = ChallengeService().getRandomCaseByDifficulty(
      selectedCategories.toList(),
      _userCategory,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChallengeDetailScreen(
          challengeCase: challengeCase,
          userCategory: _userCategory, // Pass category for display
        ),
      ),
    );
  }
}

// CHALLENGE DETAIL SCREEN
class ChallengeDetailScreen extends StatefulWidget {
  final ChallengeCase challengeCase;
  final UserCategory? userCategory; // Optional, for display purposes

  const ChallengeDetailScreen({
    super.key,
    required this.challengeCase,
    this.userCategory,
  });

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  bool _latarBelakangExpanded = true;
  bool _pokoMasalahExpanded = true;
  bool _isSubmitting = false;

  final TextEditingController _analysisController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();

  @override
  void dispose() {
    _analysisController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E232C),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            _buildHeader(),

            // CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // IMAGE
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        widget.challengeCase.imageUrl,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 180,
                            color: const Color(0xFF2B3039),
                            child: const Icon(
                              Icons.image,
                              color: Colors.grey,
                              size: 60,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // TAGS
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildTag(widget.challengeCase.topic),
                        _buildDifficultyTag(widget.challengeCase.difficulty),
                        _buildTag("Challenge"),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // LATAR BELAKANG
                    _buildExpandableSection(
                      title: "Latar Belakang / Konteks",
                      isExpanded: _latarBelakangExpanded,
                      onToggle: () => setState(
                        () => _latarBelakangExpanded = !_latarBelakangExpanded,
                      ),
                      content: widget.challengeCase.background,
                    ),

                    const SizedBox(height: 12),

                    // POKOK MASALAH
                    _buildExpandableSection(
                      title: "Pertanyaan / Tugas",
                      isExpanded: _pokoMasalahExpanded,
                      onToggle: () => setState(
                        () => _pokoMasalahExpanded = !_pokoMasalahExpanded,
                      ),
                      content: widget.challengeCase.problem,
                    ),

                    const SizedBox(height: 24),

                    // INPUT FORM
                    const Text(
                      "Jawaban & Analisis Kamu",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Berikan analismu. Apakah ini hoaks? Mengapa? Apa buktinya?",
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ANALYSIS INPUT
                    TextField(
                      controller: _analysisController,
                      maxLines: 6,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText:
                            "Tuliskan analisismu secara lengkap di sini...",
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF2B3039),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // SOURCE INPUT
                    TextField(
                      controller: _sourceController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Link Referensi / Sumber (Opsional)",
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF2B3039),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // SUBMIT BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => _submitAnswer(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C9A7),
                          disabledBackgroundColor: const Color(0xFF2B3039),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Kirim Jawaban",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Spacer(),
          Expanded(
            child: Text(
              widget.challengeCase.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48), // Balance for back button
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF00C9A7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDifficultyTag(ChallengeDifficulty difficulty) {
    Color bgColor;
    String label;

    switch (difficulty) {
      case ChallengeDifficulty.pemula:
        bgColor = const Color(0xFF4CAF50); // Green
        label = '🌱 Pemula';
        break;
      case ChallengeDifficulty.menengah:
        bgColor = const Color(0xFFFF9800); // Orange
        label = '📚 Menengah';
        break;
      case ChallengeDifficulty.lanjutan:
        bgColor = const Color(0xFFE91E63); // Pink/Red
        label = '🎯 Lanjutan';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required String content,
  }) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2B3039),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 12),
              Text(
                content,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _submitAnswer(BuildContext context) async {
    if (_analysisController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon isi analisis terlebih dahulu")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await ChallengeService().evaluateAnswer(
        widget.challengeCase,
        _analysisController.text,
        _sourceController.text,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChallengeResultScreen(result: result),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menilai jawaban: $e")));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

// CHALLENGE RESULT SCREEN (DYNAMIC)
class ChallengeResultScreen extends StatefulWidget {
  final ChallengeResult result;

  const ChallengeResultScreen({super.key, required this.result});

  @override
  State<ChallengeResultScreen> createState() => _ChallengeResultScreenState();
}

class _ChallengeResultScreenState extends State<ChallengeResultScreen> {
  String selectedTab = 'ringkasan'; // ringkasan or rincian
  bool _kekuatanExpanded = true;
  bool _feedbackExpanded = true;

  // Note: Tab controller logic simplified for brevity

  @override
  void initState() {
    super.initState();
    // Track challenge completion
    _trackChallengeCompletion();
  }

  Future<void> _trackChallengeCompletion() async {
    final score = widget.result.score;
    await userStats.completedChallenge(score);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E232C),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            _buildHeader(),

            // CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // SCORE CIRCLE
                    _buildScoreCircle(),

                    const SizedBox(height: 24),

                    // TABS
                    _buildTabs(),

                    const SizedBox(height: 20),

                    // TAB CONTENT
                    if (selectedTab == 'ringkasan') ...[
                      _buildRingkasanContent(),
                    ] else ...[
                      _buildRincianContent(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Spacer(),
          const Text(
            "Hasil Analisis",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text(
              "Selesai",
              style: TextStyle(
                color: Color(0xFF00C9A7),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCircle() {
    Color scoreColor;
    if (widget.result.score >= 80) {
      scoreColor = const Color(0xFF00C9A7); // Green
    } else if (widget.result.score >= 50) {
      scoreColor = Colors.orange; // Orange
    } else {
      scoreColor = Colors.redAccent; // Red
    }

    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [scoreColor, scoreColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: scoreColor.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${widget.result.score}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "/100",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                widget.result.verdict,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2B3039),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedTab = 'ringkasan'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedTab == 'ringkasan'
                      ? const Color(0xFF00C9A7)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Ringkasan",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selectedTab == 'ringkasan'
                        ? Colors.white
                        : Colors.grey[400],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedTab = 'rincian'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedTab == 'rincian'
                      ? const Color(0xFF00C9A7)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Rincian",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selectedTab == 'rincian'
                        ? Colors.white
                        : Colors.grey[400],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRingkasanContent() {
    return Column(
      children: [
        if (widget.result.strengths.isNotEmpty)
          _buildExpandableList(
            title: "Kekuatan",
            icon: Icons.check_circle_outline,
            items: widget.result.strengths,
            isExpanded: _kekuatanExpanded,
            onToggle: () =>
                setState(() => _kekuatanExpanded = !_kekuatanExpanded),
            color: const Color(0xFF00C9A7),
          ),

        const SizedBox(height: 12),

        if (widget.result.weaknesses.isNotEmpty)
          _buildExpandableList(
            title: "Perlu Ditingkatkan",
            icon: Icons.warning_amber_rounded,
            items: widget.result.weaknesses,
            isExpanded: true,
            onToggle: () {},
            color: Colors.orangeAccent,
          ),

        const SizedBox(height: 12),

        _buildExpandableSection(
          title: "Feedback Mentor",
          icon: Icons.school,
          content: widget.result.feedback,
          isExpanded: _feedbackExpanded,
          onToggle: () =>
              setState(() => _feedbackExpanded = !_feedbackExpanded),
        ),
      ],
    );
  }

  Widget _buildRincianContent() {
    final scores = widget.result.detailedScores;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSkillBar("Ketepatan Fakta", scores['accuracy'] ?? 0, 40),
        const SizedBox(height: 16),
        _buildSkillBar("Logika & Penalaran", scores['logic'] ?? 0, 30),
        const SizedBox(height: 16),
        _buildSkillBar("Kualitas Sumber", scores['evidence'] ?? 0, 20),
        const SizedBox(height: 16),
        _buildSkillBar("Sikap Objektif", scores['attitude'] ?? 0, 10),
      ],
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required String content,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2B3039),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 12),
              Text(
                content,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableList({
    required String title,
    required IconData icon,
    required List<String> items,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2B3039),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 12),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("- ", style: TextStyle(color: color)),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSkillBar(String label, dynamic rawValue, num maxScore) {
    final value = rawValue is num
        ? rawValue
        : num.tryParse(rawValue.toString()) ?? 0;
    final progress = (value / maxScore).clamp(0.0, 1.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "${value.toStringAsFixed(0)}/${maxScore.toStringAsFixed(0)}",
              style: const TextStyle(
                color: Color(0xFF00C9A7),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFF1E232C),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00C9A7)),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
