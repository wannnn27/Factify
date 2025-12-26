// file: lib/screens/tabs/verysense_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class VerysenseScreen extends StatefulWidget {
  const VerysenseScreen({super.key});

  @override
  State<VerysenseScreen> createState() => _VerysenseScreenState();
}

class _VerysenseScreenState extends State<VerysenseScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _videoUrlController = TextEditingController();
  File? _selectedImage;
  File? _selectedVideo;
  final ImagePicker _picker = ImagePicker();
  bool _isProcessingVideo = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    _urlController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        _showResultScreen('image');
      }
    } catch (e) {
      _showErrorSnackbar('Error memilih gambar: $e');
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    try {
      setState(() => _isProcessingVideo = true);
      
      final XFile? video = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 5), // Limit 5 minutes
      );
      
      if (video != null) {
        setState(() {
          _selectedVideo = File(video.path);
          _isProcessingVideo = false;
        });
        _showResultScreen('video');
      } else {
        setState(() => _isProcessingVideo = false);
      }
    } catch (e) {
      setState(() => _isProcessingVideo = false);
      _showErrorSnackbar('Error memilih video: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF4ECDC4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showResultScreen(String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerysenseResultScreen(analysisType: type),
      ),
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
          child: Column(
            children: [
              // App Bar
              _buildAppBar(),
              
              // Info Card
              _buildInfoCard(),
              
              const SizedBox(height: 24),
              
              // Tab Bar
              _buildTabBar(),
              
              const SizedBox(height: 24),
              
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildTextTab(),
                    _buildUrlTab(),
                    _buildCameraTab(),
                    _buildVideoTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF2D2D44).withOpacity(0.6),
                      const Color(0xFF2D2D44).withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Verysense',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Verifikasi Informasi AI',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
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
                Icon(Icons.verified, color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text(
                  'AI Powered',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
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
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.info_outline,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verifikasi Multi-Format',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Masukkan teks, URL, gambar, atau video untuk analisis mendalam',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2D2D44).withOpacity(0.6),
            const Color(0xFF2D2D44).withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4ECDC4).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.normal,
        ),
        tabs: const [
          Tab(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.text_fields, size: 20),
                SizedBox(height: 4),
                Text('Teks'),
              ],
            ),
          ),
          Tab(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.link, size: 20),
                SizedBox(height: 4),
                Text('URL'),
              ],
            ),
          ),
          Tab(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt, size: 20),
                SizedBox(height: 4),
                Text('Foto'),
              ],
            ),
          ),
          Tab(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.videocam, size: 20),
                SizedBox(height: 4),
                Text('Video'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Analisis Teks', Icons.text_fields),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2D2D44).withOpacity(0.6),
                  const Color(0xFF2D2D44).withOpacity(0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _textController,
              maxLines: 10,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Salin atau ketik informasi yang ingin Anda verifikasi...\n\nContoh: "Pemerintah mengumumkan kebijakan baru..."',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 13,
                  height: 1.5,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildVerifyButton(() {
            if (_textController.text.trim().isNotEmpty) {
              _showSuccessSnackbar('Memproses teks...');
              _showResultScreen('text');
            } else {
              _showErrorSnackbar('Mohon masukkan teks terlebih dahulu');
            }
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildUrlTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Analisis URL', Icons.link),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2D2D44).withOpacity(0.6),
                  const Color(0xFF2D2D44).withOpacity(0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _urlController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'https://contoh.com/artikel',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.link, color: Color(0xFF4ECDC4), size: 20),
              ),
              keyboardType: TextInputType.url,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoBubble(
            'Tips: Pastikan URL lengkap dan valid (dimulai dengan https://)',
            Icons.lightbulb_outline,
          ),
          const SizedBox(height: 16),
          _buildVerifyButton(() {
            if (_urlController.text.trim().isNotEmpty) {
              if (_urlController.text.startsWith('http')) {
                _showSuccessSnackbar('Menganalisis URL...');
                _showResultScreen('url');
              } else {
                _showErrorSnackbar('URL harus dimulai dengan http:// atau https://');
              }
            } else {
              _showErrorSnackbar('Mohon masukkan URL terlebih dahulu');
            }
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCameraTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4ECDC4).withOpacity(0.15),
                  const Color(0xFF4ECDC4).withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF4ECDC4).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              size: 80,
              color: Color(0xFF4ECDC4),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Verifikasi Gambar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Ambil foto atau pilih dari galeri untuk\nmemverifikasi keaslian gambar',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildActionButton(
            'Buka Kamera',
            Icons.camera_alt,
            () => _pickImage(ImageSource.camera),
            isPrimary: true,
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            'Pilih dari Galeri',
            Icons.photo_library,
            () => _pickImage(ImageSource.gallery),
            isPrimary: false,
          ),
          const SizedBox(height: 24),
          _buildInfoBubble(
            'Kami akan menganalisis metadata, manipulasi, dan keaslian gambar',
            Icons.verified_user_outlined,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildVideoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6C5CE7).withOpacity(0.15),
                  const Color(0xFF6C5CE7).withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF6C5CE7).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.videocam_outlined,
              size: 80,
              color: Color(0xFF6C5CE7),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Analisis Video',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Upload video atau masukkan URL video\nuntuk analisis deepfake & manipulasi',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Video URL Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2D2D44).withOpacity(0.6),
                  const Color(0xFF2D2D44).withOpacity(0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _videoUrlController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'https://youtube.com/watch?v=... atau TikTok URL',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.link, color: Color(0xFF6C5CE7), size: 20),
              ),
              keyboardType: TextInputType.url,
            ),
          ),
          const SizedBox(height: 16),
          _buildVerifyButton(
            () {
              if (_videoUrlController.text.trim().isNotEmpty) {
                _showSuccessSnackbar('Menganalisis video dari URL...');
                _showResultScreen('video');
              } else {
                _showErrorSnackbar('Mohon masukkan URL video terlebih dahulu');
              }
            },
            label: 'Analisis URL Video',
          ),
          
          const SizedBox(height: 24),
          
          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'ATAU',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _buildActionButton(
            _isProcessingVideo ? 'Memproses...' : 'Rekam Video',
            Icons.videocam,
            _isProcessingVideo ? null : () => _pickVideo(ImageSource.camera),
            isPrimary: true,
            color: const Color(0xFF6C5CE7),
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            _isProcessingVideo ? 'Memproses...' : 'Pilih dari Galeri',
            Icons.video_library,
            _isProcessingVideo ? null : () => _pickVideo(ImageSource.gallery),
            isPrimary: false,
            color: const Color(0xFF6C5CE7),
          ),
          
          const SizedBox(height: 24),
          
          // Video Analysis Features
          _buildFeaturesList(),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2D2D44).withOpacity(0.4),
            const Color(0xFF2D2D44).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFF5B4FCE)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.analytics, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              const Text(
                'Analisis yang Kami Lakukan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(Icons.face_outlined, 'Deteksi Deepfake'),
          _buildFeatureItem(Icons.edit_outlined, 'Manipulasi Video'),
          _buildFeatureItem(Icons.access_time, 'Analisis Timestamp'),
          _buildFeatureItem(Icons.location_on_outlined, 'Verifikasi Lokasi'),
          _buildFeatureItem(Icons.graphic_eq, 'Analisis Audio'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6C5CE7), size: 18),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
            ),
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

  Widget _buildVerifyButton(VoidCallback onPressed, {String label = 'Verifikasi Sekarang'}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4ECDC4).withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified_outlined, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback? onPressed, {
    bool isPrimary = true,
    Color? color,
  }) {
    final buttonColor = color ?? const Color(0xFF4ECDC4);
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? buttonColor : Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isPrimary ? Colors.transparent : buttonColor,
              width: 2,
            ),
          ),
          elevation: isPrimary ? 4 : 0,
          shadowColor: isPrimary ? buttonColor.withOpacity(0.4) : Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildInfoBubble(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4ECDC4).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4ECDC4).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4ECDC4), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Result Screen with Video Support
class VerysenseResultScreen extends StatefulWidget {
  final String analysisType;
  
  const VerysenseResultScreen({super.key, required this.analysisType});

  @override
  State<VerysenseResultScreen> createState() => _VerysenseResultScreenState();
}

class _VerysenseResultScreenState extends State<VerysenseResultScreen> {
  bool _showAiSummary = true;
  bool _showMainFindings = false;
  bool _showNeedAttention = false;
  bool _showAboutSource = false;
  bool _showVideoAnalysis = false;

  String _getTitle() {
    switch (widget.analysisType) {
      case 'video':
        return 'Analisis Video';
      case 'image':
        return 'Analisis Gambar';
      case 'url':
        return 'Analisis URL';
      default:
        return 'Analisis Teks';
    }
  }

  Map<String, dynamic> _getAnalysisData() {
    if (widget.analysisType == 'video') {
      return {
        'score': 68,
        'status': 'Perlu Perhatian',
        'statusColor': const Color(0xFFFFD93D),
        'source': 'Video dari TikTok/YouTube',
        'aiSummary': 'Video ini menunjukkan beberapa tanda manipulasi pada frame tertentu. Analisis deepfake mendeteksi inkonsistensi pada gerakan wajah dan sinkronisasi audio. Metadata video menunjukkan telah mengalami editing. Kami merekomendasikan untuk melakukan verifikasi tambahan sebelum membagikan konten ini.',
        'mainFindings': '• Deteksi kemungkinan deepfake: 45%\n• Manipulasi audio terdeteksi\n• Metadata menunjukkan multiple editing\n• Timestamp tidak konsisten',
        'needAttention': '• Gerakan bibir tidak sinkron dengan audio pada detik ke-12 hingga ke-18\n• Pencahayaan tidak konsisten di area wajah\n• Background blur menunjukkan pola manipulasi\n• Resolusi berbeda di beberapa frame',
        'aboutSource': 'Video pertama kali muncul di platform media sosial 3 hari yang lalu. Belum ada verifikasi dari sumber kredibel.',
      };
    }
    // Default data
    return {
      'score': 72,
      'status': 'Cukup Kredibel',
      'statusColor': const Color(0xFF4ECDC4),
      'source': 'https://examplewebsite.com/article',
      'aiSummary': 'Artikel ini memberikan gambaran yang seimbang namun kurang memiliki berbagai pihak independen. Perhatikan konten yang diambil dengan baik, meskipun beberapa klaim perlu diverifikasi lebih lanjut untuk kelengkapan informasi yang akurat dan kredibel.',
      'mainFindings': 'Temuan utama dari analisis menunjukkan bahwa sumber informasi memiliki kredibilitas yang cukup baik dengan beberapa catatan penting.',
      'needAttention': 'Beberapa klaim dalam artikel perlu verifikasi lebih lanjut. Pastikan untuk melakukan pengecekan silang dengan sumber lain.',
      'aboutSource': 'Sumber artikel berasal dari website yang memiliki reputasi baik dalam jurnalisme digital.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final data = _getAnalysisData();
    
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
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildCredibilityCard(data),
                      const SizedBox(height: 20),
                      _buildSourceCard(data),
                      if (widget.analysisType == 'video') ...[
                        const SizedBox(height: 20),
                        _buildVideoAnalysisCard(),
                      ],
                      const SizedBox(height: 20),
                      _buildExpandableCard(
                        'Ringkasan AI',
                        _showAiSummary,
                        () => setState(() => _showAiSummary = !_showAiSummary),
                        data['aiSummary'],
                        Icons.psychology,
                      ),
                      const SizedBox(height: 12),
                      _buildExpandableCard(
                        'Temuan Utama',
                        _showMainFindings,
                        () => setState(() => _showMainFindings = !_showMainFindings),
                        data['mainFindings'],
                        Icons.search,
                      ),
                      const SizedBox(height: 12),
                      _buildExpandableCard(
                        'Perlu Diperhatikan',
                        _showNeedAttention,
                        () => setState(() => _showNeedAttention = !_showNeedAttention),
                        data['needAttention'],
                        Icons.warning_amber,
                      ),
                      const SizedBox(height: 12),
                      _buildExpandableCard(
                        'Tentang Sumber',
                        _showAboutSource,
                        () => setState(() => _showAboutSource = !_showAboutSource),
                        data['aboutSource'],
                        Icons.info,
                      ),
                      const SizedBox(height: 24),
                      _buildNextSteps(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF2D2D44).withOpacity(0.6),
                      const Color(0xFF2D2D44).withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTitle(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Hasil Verifikasi Verysense',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredibilityCard(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (data['statusColor'] as Color).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Skor Kredibilitas',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: data['score'] / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(data['statusColor']),
                ),
              ),
              Column(
                children: [
                  Text(
                    '${data['score']}',
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: data['statusColor'],
                      height: 1,
                    ),
                  ),
                  const Text(
                    '/100',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: data['statusColor'],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (data['statusColor'] as Color).withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  data['status'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceCard(Map<String, dynamic> data) {
    IconData sourceIcon;
    if (widget.analysisType == 'video') {
      sourceIcon = Icons.videocam;
    } else if (widget.analysisType == 'image') {
      sourceIcon = Icons.image;
    } else if (widget.analysisType == 'url') {
      sourceIcon = Icons.link;
    } else {
      sourceIcon = Icons.article;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2D2D44).withOpacity(0.6),
            const Color(0xFF2D2D44).withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(sourceIcon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sumber ${_getTitle()}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data['source'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoAnalysisCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6C5CE7).withOpacity(0.15),
            const Color(0xFF6C5CE7).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6C5CE7).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFF5B4FCE)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.analytics, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'Analisis Detail Video',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAnalysisItem('Deepfake Detection', 45, const Color(0xFFFFD93D)),
          _buildAnalysisItem('Audio Authenticity', 60, const Color(0xFFFF6B6B)),
          _buildAnalysisItem('Metadata Integrity', 75, const Color(0xFF4ECDC4)),
          _buildAnalysisItem('Visual Consistency', 55, const Color(0xFFFFD93D)),
        ],
      ),
    );
  }

  Widget _buildAnalysisItem(String label, int score, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                ),
              ),
              Text(
                '$score%',
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableCard(
    String title,
    bool isExpanded,
    VoidCallback onTap,
    String content,
    IconData icon,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2D2D44).withOpacity(0.6),
                const Color(0xFF2D2D44).withOpacity(0.4),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4ECDC4).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: const Color(0xFF4ECDC4), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF4ECDC4),
                    size: 24,
                  ),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    content,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextSteps() {
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
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.lightbulb, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            const Text(
              'Langkah Selanjutnya',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildActionCard('Baca dari sumber lain', Icons.open_in_new),
        const SizedBox(height: 12),
        _buildActionCard('Verifikasi klaim spesifik', Icons.fact_check),
        const SizedBox(height: 12),
        _buildActionCard('Bagikan hasil analisis', Icons.share),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(title),
              backgroundColor: const Color(0xFF4ECDC4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2D2D44).withOpacity(0.4),
                const Color(0xFF2D2D44).withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF4ECDC4), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
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