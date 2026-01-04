
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:factify/services/guest_service.dart';
import 'package:factify/screens/auth/login_screen.dart';
import 'package:factify/screens/auth/register_screen.dart';

class GuestProfileScreen extends StatefulWidget {
  const GuestProfileScreen({super.key});

  @override
  State<GuestProfileScreen> createState() => _GuestProfileScreenState();
}

class _GuestProfileScreenState extends State<GuestProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _navigateToLogin() async {
    HapticFeedback.mediumImpact();
    await guestService.disableGuestMode();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _navigateToRegister() async {
    HapticFeedback.mediumImpact();
    await guestService.disableGuestMode();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: child,
              );
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Guest Avatar Section
                  _buildGuestAvatar(),
                  
                  const SizedBox(height: 32),
                  
                  // Benefits Section
                  _buildBenefitsSection(),
                  
                  const SizedBox(height: 32),
                  
                  // Features Preview
                  _buildFeaturesPreview(),
                  
                  const SizedBox(height: 32),
                  
                  // Action Buttons
                  _buildActionButtons(),
                  
                  const SizedBox(height: 24),
                  
                  // Skip exploration text
                  _buildExploreMoreText(),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuestAvatar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[800]!.withOpacity(0.3),
            Colors.grey[900]!.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[700]!.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Avatar with guest icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.grey[700]!,
                  Colors.grey[800]!,
                ],
              ),
              border: Border.all(color: Colors.grey[600]!, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.person_outline,
                color: Colors.grey,
                size: 50,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Guest label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[700]!.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.visibility,
                  color: Colors.grey[400],
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Mode Preview',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Welcome text
          const Text(
            'Halo, Tamu!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Kamu sedang menjelajahi Factify.\nLogin untuk menikmati semua fitur.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.stars, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Keuntungan Bergabung',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        _buildBenefitCard(
          icon: Icons.verified_user,
          title: 'Verysense AI',
          description: 'Akses fitur cek fakta dengan kecerdasan buatan',
          color: const Color(0xFF4ECDC4),
          isLocked: true,
        ),
        const SizedBox(height: 12),
        _buildBenefitCard(
          icon: Icons.emoji_events,
          title: 'Challenge Mode',
          description: 'Uji kemampuan literasi digital dan dapatkan poin',
          color: const Color(0xFFFFD93D),
          isLocked: true,
        ),
        const SizedBox(height: 12),
        _buildBenefitCard(
          icon: Icons.trending_up,
          title: 'Progress Tracking',
          description: 'Pantau perkembangan dan statistik belajarmu',
          color: const Color(0xFF6C5CE7),
          isLocked: true,
        ),
        const SizedBox(height: 12),
        _buildBenefitCard(
          icon: Icons.cloud_sync,
          title: 'Cloud Sync',
          description: 'Simpan data di cloud dan akses dari mana saja',
          color: const Color(0xFF5B9BD5),
          isLocked: true,
        ),
      ],
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    bool isLocked = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D44),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLocked ? Colors.grey[700]! : color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isLocked 
                  ? Colors.grey[700]!.withOpacity(0.3)
                  : color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Icon(
                  icon,
                  color: isLocked ? Colors.grey[600] : color,
                  size: 24,
                ),
                if (isLocked)
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2D44),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock,
                        color: Colors.grey[500],
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isLocked ? Colors.grey[400] : Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
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

  Widget _buildFeaturesPreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4ECDC4).withOpacity(0.15),
            const Color(0xFF6C5CE7).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4ECDC4).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF4ECDC4),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Yang Sudah Bisa Kamu Akses',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildAccessibleFeature(Icons.article, 'Baca artikel edukasi'),
          const SizedBox(height: 10),
          _buildAccessibleFeature(Icons.school, 'Akses materi Education'),
          const SizedBox(height: 10),
          _buildAccessibleFeature(Icons.lightbulb, 'Lihat tips literasi digital'),
          const SizedBox(height: 10),
          _buildAccessibleFeature(Icons.explore, 'Jelajahi seluruh konten'),
        ],
      ),
    );
  }

  Widget _buildAccessibleFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          Icons.check_circle,
          color: const Color(0xFF4ECDC4),
          size: 18,
        ),
        const SizedBox(width: 12),
        Icon(icon, color: Colors.grey[400], size: 18),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Login Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _navigateToLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4ECDC4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.login, size: 20),
                SizedBox(width: 10),
                Text(
                  'Masuk ke Akun',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Register Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _navigateToRegister,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF4ECDC4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFF4ECDC4), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add, size: 20),
                SizedBox(width: 10),
                Text(
                  'Daftar Akun Baru',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExploreMoreText() {
    return Text(
      'Atau lanjutkan menjelajah aplikasi\nsebagai tamu',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.grey[500],
        fontSize: 13,
      ),
    );
  }
}
