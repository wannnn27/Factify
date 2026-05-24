import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:factify/services/auth_service.dart';
import 'package:factify/services/user_service.dart';
import 'package:factify/services/user_stats_service.dart';
import 'package:factify/screens/auth/edit_profile_screen.dart';
import 'package:factify/screens/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _userName = 'Loading...';
  String _userEmail = '';
  String _userPhone = '';
  String _userBio = '';
  String? _userPhotoBase64;
  bool _isLoading = true;
  
  // Stats
  int _verificationCount = 0;
  int _challengeScore = 0;
  int _articlesRead = 0;
  
  // Settings
  bool _notificationsEnabled = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _loadUserData();
    _loadStats();
    _loadSettings();
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    UserProfile? localProfile = await UserService.getUserProfile();

    if (localProfile != null) {
      setState(() {
        _userName = localProfile.name.isNotEmpty ? localProfile.name : 'User Factify';
        _userEmail = localProfile.email;
        _userPhone = localProfile.phone;
        _userBio = localProfile.bio;
        _userPhotoBase64 = localProfile.photoBase64;
        _isLoading = false;
      });
    } else {
      User? user = _auth.currentUser;
      if (user != null) {
        setState(() {
          _userName = user.displayName ?? 'User Factify';
          _userEmail = user.email ?? '';
          _userPhone = user.phoneNumber ?? '';
          _userBio = 'Digital Literacy Enthusiast 🛡️';
          _isLoading = false;
        });
        
        await UserService.saveUserProfile(UserProfile(
          name: _userName,
          email: _userEmail,
          phone: _userPhone,
          bio: _userBio,
        ));
      } else {
         setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadStats() async {
    // Import at top: import 'package:factify/services/user_stats_service.dart';
    await userStats.init();
    final stats = await userStats.getAllStats();
    
    setState(() {
      _verificationCount = stats['verificationsCount'] ?? 0;
      _challengeScore = stats['highestChallengeScore'] ?? 0;
      _articlesRead = stats['articlesRead'] ?? 0;
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
  }

  Future<void> _handleLogout() async {
    HapticFeedback.mediumImpact();
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout, color: Color(0xFFFF6B6B)),
            ),
            const SizedBox(width: 12),
            const Text(
              'Keluar dari Akun?',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Semua data sesi Anda akan dihapus. Anda perlu login kembali untuk mengakses akun.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await UserService.clearUserData();
        await _authService.signOut();
        if (!mounted) return;
        
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal logout: ${e.toString()}'),
            backgroundColor: const Color(0xFFFF6B6B),
          ),
        );
      }
    }
  }

  void _editProfile() async {
    HapticFeedback.lightImpact();
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );
    
    if (result == true) {
      _loadUserData();
    }
  }

  void _showPrivacySettings() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF2D2D44),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Privasi & Keamanan',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildToggleTile(
              icon: Icons.notifications_outlined,
              title: 'Notifikasi Push',
              subtitle: 'Terima update dan pengingat',
              value: _notificationsEnabled,
              onChanged: (val) {
                setState(() => _notificationsEnabled = val);
                _saveSettings();
              },
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              icon: Icons.delete_outline,
              title: 'Hapus Data Lokal',
              subtitle: 'Menghapus cache dan preferensi',
              color: Colors.orange,
              onTap: () async {
                Navigator.pop(context);
                
                // Show confirmation dialog
                bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: const Color(0xFF2D2D44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Text('Hapus Data Lokal?', style: TextStyle(color: Colors.white)),
                    content: const Text(
                      'Apakah Anda yakin? Semua cache, riwayat, dan preferensi lokal akan dihapus.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Hapus'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data lokal berhasil dihapus'),
                      backgroundColor: Color(0xFF4ECDC4),
                    ),
                  );
                  _loadStats();
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showHelpSupport() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF2D2D44),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Bantuan & Dukungan',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildActionTile(
              icon: Icons.help_outline,
              title: 'Pusat Bantuan',
              subtitle: 'FAQ dan panduan penggunaan',
              color: const Color(0xFF4ECDC4),
              onTap: () {
                Navigator.pop(context);
                _showFAQ();
              },
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              icon: Icons.email_outlined,
              title: 'Hubungi Kami',
              subtitle: 'support@factify.id',
              color: const Color(0xFF5B9BD5),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Email: support@factify.id'),
                    backgroundColor: Color(0xFF4ECDC4),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              icon: Icons.bug_report_outlined,
              title: 'Laporkan Bug',
              subtitle: 'Bantu kami memperbaiki aplikasi',
              color: Colors.orange,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Terima kasih! Silakan kirim laporan ke bugs@factify.id'),
                    backgroundColor: Color(0xFF4ECDC4),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showFAQ() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('FAQ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFAQItem('Apa itu Factify?', 'Factify adalah aplikasi literasi digital untuk membantu Anda mengenali hoaks dan informasi palsu.'),
              _buildFAQItem('Bagaimana cara kerja Verysense?', 'Verysense menggunakan AI untuk menganalisis teks, gambar, video, dan URL untuk mendeteksi potensi hoaks.'),
              _buildFAQItem('Apakah data saya aman?', 'Ya! Data Anda disimpan secara lokal dan kami tidak membagikan informasi pribadi Anda.'),
              _buildFAQItem('Bagaimana cara menghubungi support?', 'Anda dapat mengirim email ke support@factify.id untuk bantuan.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: Color(0xFF4ECDC4))),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(color: Color(0xFF4ECDC4), fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(answer, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  void _showAboutApp() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.verified_user, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 20),
            const Text(
              'FACTIFY',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            const SizedBox(height: 4),
            const Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aplikasi Literasi Digital & Anti-Hoaks untuk Indonesia. Dilengkapi AI untuk verifikasi fakta.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              '© 2024 Team Factify',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keren! 🎉', style: TextStyle(color: Color(0xFF4ECDC4))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF4ECDC4)))
            : RefreshIndicator(
                onRefresh: () async {
                  await _loadUserData();
                  await _loadStats();
                },
                color: const Color(0xFF4ECDC4),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Header with gradient
                        _buildProfileHeader(),
                        const SizedBox(height: 24),
                        
                        // Stats Cards
                        _buildStatsSection(),
                        const SizedBox(height: 28),

                        // Account Info Section
                        _buildSectionTitle('Informasi Akun', Icons.person_outline),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          icon: Icons.email_outlined,
                          title: 'Email',
                          value: _userEmail,
                          color: const Color(0xFF5B9BD5),
                        ),
                        if (_userPhone.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            icon: Icons.phone_outlined,
                            title: 'Nomor HP',
                            value: _userPhone,
                            color: const Color(0xFF9B59B6),
                          ),
                        ],

                        const SizedBox(height: 28),

                        // Settings Section
                        _buildSectionTitle('Pengaturan', Icons.settings_outlined),
                        const SizedBox(height: 12),
                        _buildMenuCard(
                          icon: Icons.edit_outlined,
                          title: 'Edit Profil',
                          subtitle: 'Ubah foto, nama, dan bio',
                          color: const Color(0xFF4ECDC4),
                          onTap: _editProfile,
                        ),
                        const SizedBox(height: 12),
                        _buildMenuCard(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privasi & Keamanan',
                          subtitle: 'Notifikasi, tema, dan data',
                          color: const Color(0xFF9B59B6),
                          onTap: _showPrivacySettings,
                        ),

                        const SizedBox(height: 28),

                        // About Section
                        _buildSectionTitle('Tentang', Icons.info_outline),
                        const SizedBox(height: 12),
                        _buildMenuCard(
                          icon: Icons.help_outline,
                          title: 'Bantuan & Dukungan',
                          subtitle: 'FAQ, kontak, dan laporan bug',
                          color: const Color(0xFF5B9BD5),
                          onTap: _showHelpSupport,
                        ),
                        const SizedBox(height: 12),
                        _buildMenuCard(
                          icon: Icons.info_outline,
                          title: 'Tentang Factify',
                          subtitle: 'Versi, lisensi, dan tim',
                          color: const Color(0xFFF39C12),
                          onTap: _showAboutApp,
                        ),

                        const SizedBox(height: 32),

                        // Logout Button
                        _buildLogoutButton(),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4ECDC4).withValues(alpha: 0.2),
            const Color(0xFF44A08D).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF4ECDC4).withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Profile Picture with glow
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4ECDC4).withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF2D2D44),
                    border: Border.all(color: const Color(0xFF4ECDC4), width: 3),
                  ),
                  child: ClipOval(
                    child: _userPhotoBase64 != null
                        ? Image.memory(
                            base64Decode(_userPhotoBase64!),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
                          )
                        : _buildDefaultAvatar(),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _editProfile,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4ECDC4).withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            _userName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          // Bio
          Text(
            _userBio.isNotEmpty ? _userBio : 'Digital Literacy Enthusiast 🛡️',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Center(
      child: Text(
        _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
        style: const TextStyle(
          color: Color(0xFF4ECDC4),
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Verifikasi', _verificationCount.toString(), Icons.verified, const Color(0xFF4ECDC4))),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Skor Tertinggi', _challengeScore.toString(), Icons.emoji_events, const Color(0xFFF39C12))),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Artikel', _articlesRead.toString(), Icons.article, const Color(0xFF9B59B6))),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(color: Colors.grey[500], fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4ECDC4), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D44),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : '-',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D44),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4ECDC4)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: const Color(0xFF4ECDC4),
            ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _handleLogout,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B6B),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Keluar dari Akun',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
