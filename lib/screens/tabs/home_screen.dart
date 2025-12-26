// file: lib/screens/tabs/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:factify/screens/tabs/home/learn_more_screen.dart';
import 'package:factify/screens/tabs/home/tip_detail_screen.dart';
import 'package:factify/screens/tabs/home/all_articles_screen.dart';
import 'package:factify/screens/tabs/home/article_detail_screen.dart';
import 'package:factify/screens/tabs/home/all_tips_screen.dart';
import 'package:factify/widgets/home/hero_card.dart';
import 'package:factify/widgets/home/article_card.dart';
import 'package:factify/widgets/home/notification_bottom_sheet.dart';
import 'package:factify/widgets/home/search_filter_bottom_sheet.dart';
import 'package:factify/widgets/chatbot/chatbot_bottom_sheet.dart'; // ADD THIS

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  final TextEditingController _searchController = TextEditingController();
  
  // Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _userName = 'User';
  bool _isLoadingUser = true;
  int _notificationCount = 3;

  // Updated tips data
  final List<Map<String, dynamic>> tips = [
    {
      'icon': Icons.lightbulb_outline,
      'title': 'Cek Sumber Informasi',
      'subtitle': 'Pastikan informasi berasal dari sumber terpercaya sebelum membagikannya',
      'shortDescription': 'Selalu verifikasi kredibilitas sumber berita untuk menghindari penyebaran hoaks.',
      'color': const Color(0xFF4ECDC4),
      'imageUrl': 'https://www.shutterstock.com/image-vector/factchecking-vector-icons-process-verifying-260nw-2501122715.jpg',
    },
    {
      'icon': Icons.verified_outlined,
      'title': 'Verifikasi Fakta',
      'subtitle': 'Verifikasi kebenaran informasi dengan mengecek di situs fact-checking',
      'shortDescription': 'Gunakan situs fact-check terpercaya untuk memastikan keabsahan informasi.',
      'color': const Color(0xFF4ECDC4),
      'imageUrl': 'https://media.istockphoto.com/id/2166214530/vector/fact-checking-vector-icons-process-of-verifying-news-and-information-media-claims-and.jpg?s=612x612&w=0&k=20&c=Pc07IjCV5-W86EfF88YoJYQS93C3XbwgsU3in2vDevo=',
    },
    {
      'icon': Icons.shield_outlined,
      'title': 'Gunakan Password Kuat',
      'subtitle': 'Buat password yang unik dan kompleks untuk setiap akun online Anda',
      'shortDescription': 'Password kuat melindungi akun Anda dari serangan hacker dan pencurian data.',
      'color': const Color(0xFFFF6B6B),
      'imageUrl': 'https://as2.ftcdn.net/jpg/05/15/52/23/1000_F_515522392_DxRpyqrpIU0oRZjNWAYVsCyHJYLsNvSj.jpg',
    },
    {
      'icon': Icons.privacy_tip_outlined,
      'title': 'Jaga Privasi',
      'subtitle': 'Hati-hati membagikan informasi pribadi di media sosial',
      'shortDescription': 'Lindungi data pribadi Anda agar tidak disalahgunakan oleh pihak tak bertanggung jawab.',
      'color': const Color(0xFFFFD93D),
      'imageUrl': 'https://www.shutterstock.com/image-vector/cybersecurity-lock-icon-representing-digital-600nw-2502187663.jpg',
    },
  ];

  final List<Map<String, dynamic>> articles = [
    {
      'title': 'Lindungi Data Pribadi Anda di Internet',
      'description': 'Tips praktis untuk menjaga privasi dan keamanan data pribadi Anda saat beraktivitas online',
      'category': 'Keamanan Digital',
      'readTime': '5 min read',
      'views': '2.5K views',
      'image': 'assets/images/data-privacy.png',
      'content': 'Di era digital ini, melindungi data pribadi sangat penting. Berikut beberapa tips:\n\n1. Gunakan password yang kuat dan unik untuk setiap akun\n2. Aktifkan autentikasi dua faktor\n3. Hati-hati dengan informasi yang Anda bagikan di media sosial\n4. Periksa pengaturan privasi secara berkala\n5. Hindari menggunakan WiFi publik untuk transaksi sensitif\n6. Update perangkat lunak secara rutin\n\nDengan mengikuti langkah-langkah ini, Anda dapat menjaga keamanan data pribadi Anda di dunia digital.',
      'author': 'Tim Factify',
      'date': '15 Des 2024',
    },
    {
      'title': 'Mengenali Hoaks dan Berita Palsu',
      'description': 'Panduan lengkap cara mengidentifikasi berita palsu dan hoaks di media sosial',
      'category': 'Media Literacy',
      'readTime': '7 min read',
      'views': '3.2K views',
      'image': 'assets/images/fake_news.jpg',
      'content': 'Hoaks dan berita palsu semakin marak di media sosial. Berikut cara mengenalinya:\n\n1. Periksa sumber berita - apakah kredibel?\n2. Cek tanggal publikasi - apakah masih relevan?\n3. Verifikasi dengan sumber lain\n4. Waspadai judul yang sensasional\n5. Periksa penulis dan kredibilitasnya\n6. Gunakan situs fact-checking\n\nJangan langsung percaya dan share tanpa verifikasi. Mari bersama-sama melawan penyebaran hoaks!',
      'author': 'Tim Factify',
      'date': '12 Des 2024',
    },
    {
      'title': 'Etika Bermedia Sosial yang Baik',
      'description': 'Pelajari cara berinteraksi dengan bijak dan bertanggung jawab di platform media sosial',
      'category': 'Digital Ethics',
      'readTime': '4 min read',
      'views': '1.8K views',
      'image': 'assets/images/digital_ethics.png',
      'content': 'Bermedia sosial dengan etika yang baik sangat penting. Berikut panduannya:\n\n1. Hormati pendapat orang lain\n2. Hindari cyberbullying\n3. Jangan menyebarkan ujaran kebencian\n4. Verifikasi sebelum membagikan informasi\n5. Jaga privasi diri dan orang lain\n6. Gunakan bahasa yang sopan\n\nDengan menerapkan etika bermedia sosial, kita dapat menciptakan ruang digital yang lebih positif dan aman.',
      'author': 'Tim Factify',
      'date': '10 Des 2024',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _animationController.forward();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userData = await _firestore.collection('users').doc(user.uid).get();
        if (userData.exists) {
          setState(() {
            _userName = userData.get('username') ?? user.displayName ?? 'User';
            _isLoadingUser = false;
          });
        } else {
          setState(() {
            _userName = user.displayName ?? 'User';
            _isLoadingUser = false;
          });
        }
      } else {
        setState(() {
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _userName = _auth.currentUser?.displayName ?? 'User';
        _isLoadingUser = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showNotifications() {
    setState(() {
      _notificationCount = 0;
    });
    showNotificationBottomSheet(context);
  }

  void _showSearchFilter() {
    showSearchFilterBottomSheet(context);
  }

  // ADD THIS METHOD FOR CHATBOT
  void _showChatbot() {
    showChatbotBottomSheet(context);
  }

  void _navigateToLearnMore() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LearnMoreScreen()),
    );
  }

  void _navigateToAllTips() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AllTipsScreen(tips: tips)),
    );
  }

  void _navigateToAllArticles() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AllArticlesScreen(articles: articles)),
    );
  }

  void _navigateToArticleDetail(Map<String, dynamic> article) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ArticleDetailScreen(article: article)),
    );
  }

  void _navigateToTipDetail(Map<String, dynamic> tip) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TipDetailScreen(tip: tip)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F0F1E),
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E).withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: _buildHeader(),
                      ),
                    );
                  },
                ),
              ),
              
              // Search Bar
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value * 1.5),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: _buildSearchBar(),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Quick Stats
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value * 2),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: _buildQuickStats(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Hero Card
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value * 2.5),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: HeroCard(onTap: _navigateToLearnMore),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Tips Section Header
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value * 3),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                          child: _buildSectionHeader(
                            'Tips Literasi Digital',
                            'Lihat Semua',
                            _navigateToAllTips,
                            Icons.lightbulb,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Tips List (hanya tampilkan 2 di home)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final tip = tips[index];
                      return AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _slideAnimation.value * (3.5 + index * 0.3)),
                            child: Opacity(
                              opacity: _fadeAnimation.value,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildEnhancedTipCard(tip),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: 2,
                  ),
                ),
              ),
              
              // Articles Section Header
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value * 4),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                          child: _buildSectionHeader(
                            'Artikel Terpercaya',
                            'Selengkapnya',
                            _navigateToAllArticles,
                            Icons.article,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Articles List
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final article = articles[index];
                      return AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _slideAnimation.value * (4.5 + index * 0.3)),
                            child: Opacity(
                              opacity: _fadeAnimation.value,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: ArticleCard(
                                  article: article,
                                  onTap: () => _navigateToArticleDetail(article),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: articles.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // ADD FLOATING ACTION BUTTON FOR CHATBOT
      floatingActionButton: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _fadeAnimation.value,
            child: FloatingActionButton(
              onPressed: _showChatbot,
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C5CE7).withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipOval(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/images/CHATBOT.webp',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4ECDC4),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ==================== WIDGETS ====================
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.wb_sunny, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Selamat Datang',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _isLoadingUser
                    ? Container(
                        height: 28,
                        width: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D2D44),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      )
                    : Text(
                        _userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showNotifications,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF2D2D44).withOpacity(0.6),
                      const Color(0xFF2D2D44).withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4ECDC4).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    const Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFF4ECDC4),
                      size: 24,
                    ),
                    if (_notificationCount > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: ScaleTransition(
                          scale: _pulseAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF6B6B).withOpacity(0.5),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              _notificationCount > 9 ? '9+' : '$_notificationCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4ECDC4).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Icon(Icons.search, color: Colors.grey, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Cari tips, artikel, atau topik...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text('Mencari: $value'),
                          ],
                        ),
                        backgroundColor: const Color(0xFF4ECDC4),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showSearchFilter,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4ECDC4).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.tune,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.article_outlined,
            label: 'Artikel',
            value: '${articles.length}',
            color: const Color(0xFF4ECDC4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.tips_and_updates_outlined,
            label: 'Tips',
            value: '${tips.length}',
            color: const Color(0xFFFFD93D),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.verified_outlined,
            label: 'Terverifikasi',
            value: '100%',
            color: const Color(0xFF6C5CE7),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String actionText,
    VoidCallback onTap,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF4ECDC4).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF4ECDC4).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionText,
                    style: const TextStyle(
                      color: Color(0xFF4ECDC4),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF4ECDC4),
                    size: 12,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedTipCard(Map<String, dynamic> tip) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToTipDetail(tip),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (tip['color'] as Color).withOpacity(0.15),
                (tip['color'] as Color).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (tip['color'] as Color).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tip['color'],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (tip['color'] as Color).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  tip['icon'],
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tip['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tip['subtitle'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}