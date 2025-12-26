// file: lib/screens/tabs/challenge_screen.dart
import 'package:flutter/material.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  // Selected categories
  Set<String> selectedCategories = {};

  final List<Map<String, dynamic>> categories = [
    {
      'id': 'teknologi',
      'title': 'Teknologi',
      'icon': Icons.computer,
      'description': 'Hoaks seputar AI, gadget, keamanan digital, dan teknologi terbaru.',
    },
    {
      'id': 'pendidikan',
      'title': 'Pendidikan',
      'icon': Icons.school,
      'description': 'Isu fakta dan misinformasi di dunia sekolah, kampus, dan beasiswa.',
    },
    {
      'id': 'sosial',
      'title': 'Sosial',
      'icon': Icons.people,
      'description': 'Rumor, berita viral, dan isu sosial yang sering disalahpahami.',
    },
    {
      'id': 'ekonomi',
      'title': 'Ekonomi',
      'icon': Icons.trending_up,
      'description': 'Hoaks investasi, keuangan, dan bisnis yang menyesatkan.',
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
            "Uji kemampuanmu dalam membedakan fakta dengan hoaks sekarang!",
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChallengeDetailScreen(
          selectedCategories: selectedCategories.toList(),
        ),
      ),
    );
  }
}

// CHALLENGE DETAIL SCREEN
class ChallengeDetailScreen extends StatefulWidget {
  final List<String> selectedCategories;

  const ChallengeDetailScreen({
    super.key,
    required this.selectedCategories,
  });

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  bool _latarBelakangExpanded = false;
  bool _pokoMasalahExpanded = false;
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
                        'https://images.unsplash.com/photo-1587370560942-ad2a04eabb6d?w=800',
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
                        _buildTag("Teknologi"),
                        _buildTag("Sosial"),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // LATAR BELAKANG
                    _buildExpandableSection(
                      title: "Latar Belakang",
                      isExpanded: _latarBelakangExpanded,
                      onToggle: () => setState(() => _latarBelakangExpanded = !_latarBelakangExpanded),
                      content: "Informasi keliru mengenai vaksin telah menyebar luas melalui platform media sosial, menyebabkan keraguan publik dan penurunan angka vaksinasi. Kasus ini menciptakan tantangan serius bagi kesehatan masyarakat dan diperkuat oleh algoritma menciptakan tantangan serius bagi kesehatan masyarakat.",
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // POKOK MASALAH
                    _buildExpandableSection(
                      title: "Pokok Masalah",
                      isExpanded: _pokoMasalahExpanded,
                      onToggle: () => setState(() => _pokoMasalahExpanded = !_pokoMasalahExpanded),
                      content: "Bagaimana misinformasi tentang vaksin menyebar di media sosial dan apa dampaknya terhadap kepercayaan publik?",
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // TUGAS
                    const Text(
                      "Tugas",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Analisis situasi, bentuk kesimpulan, dan justifikasi dengan penelaran yang kuat serta sumber yang dapat dipercaya di kolom bawah ini.",
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
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Tuliskan analisis dan justifikasi Anda di sini...",
                        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
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
                        hintText: "Tambah Sumber... (contoh: https://website.com)",
                        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
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
                        onPressed: () => _submitAnswer(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C9A7),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
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
          const Text(
            "Informasi Vaksin",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
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
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
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

  void _submitAnswer(BuildContext context) {
    if (_analysisController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon isi analisis terlebih dahulu")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChallengeResultScreen(),
      ),
    );
  }
}

// CHALLENGE RESULT SCREEN
class ChallengeResultScreen extends StatefulWidget {
  const ChallengeResultScreen({super.key});

  @override
  State<ChallengeResultScreen> createState() => _ChallengeResultScreenState();
}

class _ChallengeResultScreenState extends State<ChallengeResultScreen> {
  String selectedTab = 'ringkasan'; // ringkasan or rincian
  bool _kekuatanExpanded = false;

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
            "Informasi Vaksin",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              // Done action
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text(
              "Done",
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
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF00C9A7), Color(0xFF0088CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 201, 167, 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "80",
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "/100",
              style: TextStyle(
                color: const Color.fromRGBO(255, 255, 255, 0.8),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Analisis yang Baik!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
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
        _buildExpandableSection(
          title: "Kekuatan",
          icon: Icons.check_circle_outline,
          isExpanded: _kekuatanExpanded,
          onToggle: () => setState(() => _kekuatanExpanded = !_kekuatanExpanded),
          content: "Kamu menunjukkan pemahaman tesis yang lebih dan menentukan topik primer dengan baik untuk mendukung poin-poin kritis. Argumenmu tersusun dengan baik dan mudah diikuti.",
        ),
        const SizedBox(height: 12),
        _buildExpandableSection(
          title: "Area yang Perlu Ditingkatkan",
          icon: Icons.arrow_upward,
          isExpanded: false,
          onToggle: () {},
          content: "Perlu pendalaman lebih lanjut pada aspek metodologi penelitian.",
        ),
      ],
    );
  }

  Widget _buildRincianContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Penalaran & Logika",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildProgressBar("Kejujuran", 0.9, Colors.blue),
        const SizedBox(height: 8),
        _buildProgressBar("Bukti", 0.75, Colors.orange),
        const SizedBox(height: 8),
        _buildProgressBar("Logika", 0.85, const Color(0xFF00C9A7)),
      ],
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
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
              children: [
                Icon(icon, color: const Color(0xFF00C9A7), size: 20),
                const SizedBox(width: 8),
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
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
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

  Widget _buildProgressBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: const Color(0xFF2B3039),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}