import 'package:flutter/material.dart';
import 'package:factify/services/guest_service.dart';
import 'package:factify/screens/main_navigation.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _contents = [
    {
      "image": "assets/images/onboarding_1.png", 
      "title": "Belajar Kenali Hoaks",
      "desc": "Materi singkat dan interaktif untuk memahami informasi digital dengan lebih baik."
    },
    {
      "image": "assets/images/onboarding_2.png", 
      "title": "Cek Keaslian Informasi",
      "desc": "Gunakan fitur scan pintar kami untuk memverifikasi berita yang meragukan."
    },
    {
      "image": "assets/images/onboarding_3.png", 
      "title": "Uji Berpikir Kritis",
      "desc": "Tantang dirimu dengan kasus nyata dan tingkatkan level literasi digitalmu."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E232C),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER (TOMBOL SKIP SAJA)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // TOMBOL SKIP
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    ),
                    child: const Text(
                      "Skip",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // BAGIAN TENGAH (GAMBAR & TEKS)
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _contents.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate image height based on available space
                      final maxImageHeight = constraints.maxHeight * 0.45;
                      
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              // BAGIAN GAMBAR (responsive)
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: maxImageHeight.clamp(150, 280),
                                ),
                                child: Image.asset(
                                  _contents[index]["image"]!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // BAGIAN JUDUL
                              Text(
                                _contents[index]["title"]!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // BAGIAN DESKRIPSI
                              Text(
                                _contents[index]["desc"]!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // BAGIAN BAWAH
            if (_currentIndex == _contents.length - 1)
              _buildFinalButtons()
            else
              _buildNavigationRow(),
          ],
        ),
      ),
    );
  }
  
  // Navigation row for non-final pages
  Widget _buildNavigationRow() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // TOMBOL BACK (muncul setelah halaman pertama)
          AnimatedOpacity(
            opacity: _currentIndex > 0 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: _currentIndex > 0
                ? Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF2B3039),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => _controller.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      ),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF00C9A7),
                        size: 24,
                      ),
                    ),
                  )
                : const SizedBox(width: 48),
          ),
          
          // Indikator Titik-titik
          Row(
            children: List.generate(
              _contents.length,
              (index) => buildDot(index),
            ),
          ),
          
          // Tombol Next
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF2B3039),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => _controller.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
              ),
              icon: const Icon(
                Icons.arrow_forward,
                color: Color(0xFF00C9A7),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Final page buttons with Login and Preview options
  Widget _buildFinalButtons() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _contents.length,
              (index) => buildDot(index),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Login Button (Primary)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C9A7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text(
                    "Masuk / Daftar",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Preview Button (Secondary)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                // Enable guest mode
                await guestService.enableGuestMode();
                if (!mounted) return;
                
                // Navigate to main app in guest mode
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.grey[600]!, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.visibility, color: Colors.grey[400], size: 20),
                  const SizedBox(width: 10),
                  Text(
                    "Lihat Dulu",
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Info text
          Text(
            "Jelajahi aplikasi tanpa login dulu",
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Widget Indikator Halaman (Titik-titik)
  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: _currentIndex == index ? 25 : 8,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _currentIndex == index
            ? const Color(0xFF00C9A7)
            : const Color.fromRGBO(158, 158, 158, 0.3),
      ),
    );
  }
}