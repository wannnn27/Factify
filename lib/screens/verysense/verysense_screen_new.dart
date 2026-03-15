import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/verification_result.dart';
import '../../services/verysense_service.dart';
import '../../widgets/verysense/loading_screen.dart';
import 'verysense_result_screen.dart';

class VerysenseScreenNew extends StatefulWidget {
  const VerysenseScreenNew({super.key});

  @override
  State<VerysenseScreenNew> createState() => _VerysenseScreenNewState();
}

class _VerysenseScreenNewState extends State<VerysenseScreenNew>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _videoUrlController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isProcessingVideo = false;
  bool _isLoading = false;
  bool _isApiAvailable = false;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _checkApiHealth();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    _urlController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  /// Check if API is available
  Future<void> _checkApiHealth() async {
    final isHealthy = await VerysenseService.checkHealth();
    setState(() => _isApiAvailable = isHealthy);

    if (!isHealthy && mounted) {
      _showWarningSnackbar(
        'Server AI tidak tersedia. Pastikan server ML berjalan.',
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          await _performVerification(
            contentType: ContentType.image,
            verifyFunction: () => VerysenseService.verifyImageBytes(bytes, image.name),
          );
        } else {
          _verifyImage(image);
        }
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
        maxDuration: const Duration(minutes: 5),
      );

      if (video != null) {
        setState(() => _isProcessingVideo = false);
        if (kIsWeb) {
          final bytes = await video.readAsBytes();
          await _performVerification(
            contentType: ContentType.video,
            verifyFunction: () => VerysenseService.verifyVideoBytes(bytes, video.name),
          );
        } else {
        _verifyVideo(video);
        }
      } else {
        setState(() => _isProcessingVideo = false);
      }
    } catch (e) {
      setState(() => _isProcessingVideo = false);
      _showErrorSnackbar('Error memilih video: $e');
    }
  }


  /// Verify text content
  Future<void> _verifyText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      _showErrorSnackbar('Mohon masukkan teks terlebih dahulu');
      return;
    }

    await _performVerification(
      contentType: ContentType.text,
      verifyFunction: () => VerysenseService.verifyText(text),
    );
  }

  /// Verify URL
  Future<void> _verifyUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showErrorSnackbar('Mohon masukkan URL terlebih dahulu');
      return;
    }

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      _showWarningSnackbar('URL akan diperlakukan sebagai https://$url');
    }

    await _performVerification(
      contentType: ContentType.url,
      verifyFunction: () => VerysenseService.verifyUrl(url),
    );
  }

  /// Verify image file
  Future<void> _verifyImage(XFile imageFile) async {
    await _performVerification(
      contentType: ContentType.image,
      verifyFunction: () => VerysenseService.verifyImageFile(imageFile),
    );
  }

  /// Verify video file
  Future<void> _verifyVideo(XFile videoFile) async {
    await _performVerification(
      contentType: ContentType.video,
      verifyFunction: () => VerysenseService.verifyVideoFile(videoFile),
    );
  }

  /// Verify video from URL
  Future<void> _verifyVideoUrl() async {
    final url = _videoUrlController.text.trim();
    if (url.isEmpty) {
      _showErrorSnackbar('Mohon masukkan URL video terlebih dahulu');
      return;
    }

    await _performVerification(
      contentType: ContentType.video,
      verifyFunction: () => VerysenseService.verifyVideoUrl(url),
    );
  }

  /// Perform verification with loading screen
  Future<void> _performVerification({
    required ContentType contentType,
    required Future<VerificationResult> Function() verifyFunction,
  }) async {
    if (!_isApiAvailable) {
      _showErrorSnackbar(
        'Server AI tidak tersedia. Periksa koneksi dan coba lagi.',
      );
      await _checkApiHealth();
      return;
    }

    // Show loading screen
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerysenseLoadingScreen(
            contentType: contentType,
            onCancel: () => Navigator.pop(context),
          ),
        ),
      );
    }

    try {
      final result = await verifyFunction();

      // Pop loading screen and push result screen
      if (mounted) {
        Navigator.pop(context); // Pop loading
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerysenseResultScreen(result: result),
          ),
        );
      }
    } on VerysenseException catch (e) {
      if (mounted) Navigator.pop(context); // Pop loading
      _showErrorSnackbar('Error: ${e.message}');
    } catch (e) {
      if (mounted) Navigator.pop(context); // Pop loading
      _showErrorSnackbar('Terjadi kesalahan: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
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
        duration: const Duration(seconds: 4),
      ),
    );
  }


  void _showWarningSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFFFD93D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0F1E),
              Color(0xFF1A1A2E),
              Color(0xCC16213E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildInfoCard(),
              const SizedBox(height: 24),
              _buildTabBar(),
              const SizedBox(height: 24),
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
                  gradient: const LinearGradient(
                    colors: [
                      Color(0x992D2D44),
                      Color(0x4D2D2D44),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white10,
                    width: 1,
                  ),
                ),
                child:
                    const Icon(Icons.arrow_back, color: Colors.white, size: 20),
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
                const Text(
                  'Verifikasi Informasi AI',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // API Status Indicator
          GestureDetector(
            onTap: _checkApiHealth,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isApiAvailable
                      ? [const Color(0xFF4ECDC4), const Color(0xFF44A08D)]
                      : [const Color(0xFFFF6B6B), const Color(0xFFEE5A5A)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isApiAvailable ? Icons.verified : Icons.cloud_off,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isApiAvailable ? 'AI Online' : 'Offline',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
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
          gradient: const LinearGradient(
            colors: [
              Color(0xF2FFFFFF),
              Color(0xE6FFFFFF),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x334ECDC4),
              blurRadius: 20,
              offset: Offset(0, 8),
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
                    'Masukkan teks, URL, gambar, atau video untuk analisis mendalam dengan AI',
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
        gradient: const LinearGradient(
          colors: [
            Color(0x992D2D44),
            Color(0x662D2D44),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white10,
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
          boxShadow: const [
            BoxShadow(
              color: Color(0x4D4ECDC4),
              blurRadius: 8,
              offset: Offset(0, 2),
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
              gradient: const LinearGradient(
                colors: [
                  Color(0x992D2D44),
                  Color(0x662D2D44),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white10,
                width: 1,
              ),
            ),
            child: TextField(
              controller: _textController,
              maxLines: 10,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText:
                    'Salin atau ketik informasi yang ingin Anda verifikasi...\n\nContoh: "Pemerintah mengumumkan kebijakan baru..."',
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
          _buildVerifyButton(_verifyText),
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
              gradient: const LinearGradient(
                colors: [
                  Color(0x992D2D44),
                  Color(0x662D2D44),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white10,
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
                prefixIcon:
                    const Icon(Icons.link, color: Color(0xFF4ECDC4), size: 20),
              ),
              keyboardType: TextInputType.url,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoBubble(
            'Tips: Masukkan URL lengkap untuk hasil analisis yang optimal',
            Icons.lightbulb_outline,
          ),
          const SizedBox(height: 16),
          _buildVerifyButton(_verifyUrl),
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
              gradient: const LinearGradient(
                colors: [
                  Color(0x264ECDC4),
                  Color(0x0D4ECDC4),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0x4D4ECDC4),
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
          const Text(
            'Ambil foto atau pilih dari galeri untuk\nmemverifikasi keaslian gambar',
            style: TextStyle(
              color: Colors.white70,
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
            'AI akan menganalisis metadata, deteksi manipulasi (ELA), dan keaslian gambar',
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
              gradient: const LinearGradient(
                colors: [
                  Color(0x266C5CE7),
                  Color(0x0D6C5CE7),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0x4D6C5CE7),
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
          const Text(
            'Upload video atau masukkan URL video\nuntuk analisis deepfake & manipulasi',
            style: TextStyle(
              color: Colors.white70,
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
              gradient: const LinearGradient(
                colors: [
                  Color(0x992D2D44),
                  Color(0x662D2D44),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white10,
                width: 1,
              ),
            ),
            child: TextField(
              controller: _videoUrlController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'https://youtube.com/watch?v=... atau URL video',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                border: InputBorder.none,
                prefixIcon:
                    const Icon(Icons.link, color: Color(0xFF6C5CE7), size: 20),
              ),
              keyboardType: TextInputType.url,
            ),
          ),
          const SizedBox(height: 16),
          _buildVerifyButton(
            _verifyVideoUrl,
            label: 'Analisis URL Video',
          ),

          const SizedBox(height: 24),

          // Divider
          const Row(
            children: [
              Expanded(child: Divider(color: Colors.white24)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'ATAU',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.white24)),
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
        gradient: const LinearGradient(
          colors: [
            Color(0x662D2D44),
            Color(0x332D2D44),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white10,
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
                child:
                    const Icon(Icons.analytics, color: Colors.white, size: 16),
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
          _buildFeatureItem(Icons.access_time, 'Analisis Temporal'),
          _buildFeatureItem(Icons.graphic_eq, 'Analisis Audio'),
          _buildFeatureItem(Icons.analytics_outlined, 'Konsistensi Visual'),
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
            style: const TextStyle(
              color: Colors.white70,
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

  Widget _buildVerifyButton(VoidCallback onPressed,
      {String label = 'Verifikasi Sekarang'}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
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
            boxShadow: const [
              BoxShadow(
                color: Color(0x664ECDC4),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                else
                  const Icon(Icons.verified_outlined,
                      color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  _isLoading ? 'Memproses...' : label,
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
          shadowColor:
              isPrimary ? buttonColor.withAlpha(102) : Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildInfoBubble(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x1A4ECDC4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0x4D4ECDC4),
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
              style: const TextStyle(
                color: Colors.white70,
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
