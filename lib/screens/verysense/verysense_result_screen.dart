
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/verification_result.dart';
import '../../widgets/verysense/result_card.dart';
import '../../services/user_stats_service.dart';

class VerysenseResultScreen extends StatefulWidget {
  final VerificationResult result;

  const VerysenseResultScreen({
    super.key,
    required this.result,
  });

  @override
  State<VerysenseResultScreen> createState() => _VerysenseResultScreenState();
}

class _VerysenseResultScreenState extends State<VerysenseResultScreen>
    with TickerProviderStateMixin {
  bool _showAiSummary = true;
  bool _showMainFindings = false;
  bool _showNeedAttention = false;
  bool _showAboutSource = false;

  late AnimationController _scoreAnimationController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _scoreAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Track verification completion
    _trackVerification();
    
    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scoreAnimation = Tween<double>(begin: 0, end: widget.result.score).animate(
      CurvedAnimation(
        parent: _scoreAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scoreAnimationController.forward();
    _fadeController.forward();
  }
  
  Future<void> _trackVerification() async {
    await userStats.completedVerification();
  }

  @override
  void dispose() {
    _scoreAnimationController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String _getTitle() {
    switch (widget.result.contentType) {
      case ContentType.video:
        return 'Analisis Video';
      case ContentType.image:
        return 'Analisis Gambar';
      case ContentType.url:
        return 'Analisis URL';
      case ContentType.text:
        return 'Analisis Teks';
    }
  }

  IconData _getContentIcon() {
    switch (widget.result.contentType) {
      case ContentType.video:
        return Icons.play_circle_outline;
      case ContentType.image:
        return Icons.image_outlined;
      case ContentType.url:
        return Icons.link;
      case ContentType.text:
        return Icons.text_fields;
    }
  }

  void _shareResult() {
    HapticFeedback.mediumImpact();
    final result = widget.result;
    final shareText = '''
Hasil Verifikasi Verysense

Skor Kredibilitas: ${result.score.round()}/100
Status: ${result.status.label}

Ringkasan AI:
${result.aiSummary}

🔍 Temuan Utama:
${result.mainFindings}

⚠️ Perlu Diperhatikan:
${result.needAttention}

---
Dianalisis oleh Factify - Aplikasi Literasi Digital
    ''';

    Share.share(shareText, subject: 'Hasil Verifikasi Factify');
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Column(
                        children: [
                          _buildHeroScoreCard(result),
                          const SizedBox(height: 24),
                          _buildQuickStatsRow(result),
                          const SizedBox(height: 24),
                          _buildGlassSourceCard(result),
                          if (result.contentType == ContentType.video &&
                              result.videoDetail != null) ...[
                            const SizedBox(height: 20),
                            VideoAnalysisCard(detail: result.videoDetail!),
                          ],
                          if (result.contentType == ContentType.image &&
                              result.imageDetail != null) ...[
                            const SizedBox(height: 20),
                            ImageAnalysisCard(detail: result.imageDetail!),
                          ],
                          if (result.contentType == ContentType.text &&
                              result.textDetail != null) ...[
                            const SizedBox(height: 20),
                            TextAnalysisCard(detail: result.textDetail!),
                          ],
                          const SizedBox(height: 24),
                          _buildSectionTitle('Detail Analisis', Icons.analytics),
                          const SizedBox(height: 16),
                          _buildExpandableCard(
                            'Ringkasan AI',
                            result.aiSummary,
                            Icons.auto_awesome,
                            _showAiSummary,
                            () => setState(() => _showAiSummary = !_showAiSummary),
                            const Color(0xFF6C5CE7),
                          ),
                          const SizedBox(height: 12),
                          _buildExpandableCard(
                            'Temuan Utama',
                            result.mainFindings,
                            Icons.find_in_page,
                            _showMainFindings,
                            () => setState(() => _showMainFindings = !_showMainFindings),
                            const Color(0xFF00CEC9),
                          ),
                          const SizedBox(height: 12),
                          _buildExpandableCard(
                            'Perlu Diperhatikan',
                            result.needAttention,
                            Icons.warning_amber_rounded,
                            _showNeedAttention,
                            () => setState(() => _showNeedAttention = !_showNeedAttention),
                            const Color(0xFFFDCB6E),
                          ),
                          const SizedBox(height: 12),
                          _buildExpandableCard(
                            'Tentang Sumber',
                            result.aboutSource,
                            Icons.source_outlined,
                            _showAboutSource,
                            () => setState(() => _showAboutSource = !_showAboutSource),
                            const Color(0xFF74B9FF),
                          ),
                          const SizedBox(height: 32),
                          _buildNextStepsSection(),
                          const SizedBox(height: 24),
                          _buildAnalysisTimeBadge(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0A0A14),
                Color(0xFF0F0F1E),
                Color(0xFF141428),
              ],
            ),
          ),
        ),
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  widget.result.statusColor.withAlpha(38),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 200,
          left: -80,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF6C5CE7).withAlpha(26),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          _buildGlassButton(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_getContentIcon(), color: widget.result.statusColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _getTitle(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: widget.result.statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Verysense AI Analysis',
                      style: TextStyle(
                        color: Colors.white.withAlpha(128),
                        fontSize: 12,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildGradientButton(
            onTap: _shareResult,
            color: widget.result.statusColor,
            child: const Icon(Icons.share_rounded, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton({required VoidCallback onTap, required Widget child}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(13),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withAlpha(26)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(51),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required VoidCallback onTap,
    required Color color,
    required Widget child,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withAlpha(179)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(77),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildHeroScoreCard(VerificationResult result) {
    return AnimatedBuilder(
      animation: _scoreAnimationController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withAlpha(26),
                Colors.white.withAlpha(13),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withAlpha(26)),
            boxShadow: [
              BoxShadow(
                color: result.statusColor.withAlpha(51),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: result.statusColor.withAlpha(77),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: 1,
                      strokeWidth: 10,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withAlpha(26),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: _scoreAnimation.value / 100,
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(result.statusColor),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _scoreAnimation.value.round().toString(),
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w800,
                          color: result.statusColor,
                          height: 1,
                          letterSpacing: -2,
                        ),
                      ),
                      Text(
                        'dari 100',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withAlpha(128),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [result.statusColor, result.statusColor.withAlpha(204)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: result.statusColor.withAlpha(102),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(result.status.icon, color: Colors.white, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        result.status.label,
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_outlined, 
                    color: Colors.white.withAlpha(102), size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Confidence: ${(result.confidence * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: Colors.white.withAlpha(102),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStatsRow(VerificationResult result) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickStat(
            icon: Icons.speed,
            label: 'Waktu',
            value: '${result.analysisTime.toStringAsFixed(1)}s',
            color: const Color(0xFF74B9FF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickStat(
            icon: Icons.analytics_outlined,
            label: 'Akurasi',
            value: '${(result.confidence * 100).toStringAsFixed(0)}%',
            color: const Color(0xFF00CEC9),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickStat(
            icon: result.contentType.icon,
            label: 'Tipe',
            value: result.contentType.displayName,
            color: const Color(0xFFA29BFE),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withAlpha(128),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassSourceCard(VerificationResult result) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withAlpha(20),
            Colors.white.withAlpha(8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(26)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  result.statusColor.withAlpha(77),
                  result.statusColor.withAlpha(26),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(result.contentType.icon, color: result.statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sumber ${result.contentType.displayName}',
                  style: TextStyle(
                    color: Colors.white.withAlpha(128),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.source,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableCard(
    String title,
    String content,
    IconData icon,
    bool isExpanded,
    VoidCallback onTap,
    Color color,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isExpanded
                  ? [color.withAlpha(38), color.withAlpha(13)]
                  : [Colors.white.withAlpha(15), Colors.white.withAlpha(5)],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isExpanded ? color.withAlpha(77) : Colors.white.withAlpha(20),
              width: isExpanded ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withAlpha(isExpanded ? 51 : 26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: isExpanded ? color : Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withAlpha(26),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: color,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: isExpanded
                    ? Column(
                        children: [
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(51),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              content.isNotEmpty 
                                  ? content 
                                  : 'Tidak ada informasi tersedia.',
                              style: TextStyle(
                                color: Colors.white.withAlpha(204),
                                fontSize: 13,
                                height: 1.7,
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextStepsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Langkah Selanjutnya', Icons.lightbulb_outline),
        const SizedBox(height: 16),
        _buildActionCard(
          'Baca dari sumber lain',
          'Bandingkan informasi dengan media lain',
          Icons.open_in_new_rounded,
          const Color(0xFF74B9FF),
          () => _showSnackbar('Membuka sumber alternatif...'),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          'Verifikasi klaim spesifik',
          'Periksa fakta secara detail',
          Icons.fact_check_rounded,
          const Color(0xFF00CEC9),
          () => _showSnackbar('Memverifikasi klaim...'),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          'Bagikan hasil analisis',
          'Sebarkan informasi verifikasi ini',
          Icons.share_rounded,
          const Color(0xFFA29BFE),
          _shareResult,
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [color.withAlpha(26), color.withAlpha(8)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withAlpha(38)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(38),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withAlpha(128),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: color,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisTimeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4ECDC4).withAlpha(38),
            const Color(0xFF44A08D).withAlpha(13),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF4ECDC4).withAlpha(51)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt, color: Color(0xFF4ECDC4), size: 18),
          const SizedBox(width: 10),
          Text(
            'Dianalisis dalam ${widget.result.analysisTime.toStringAsFixed(2)} detik',
            style: const TextStyle(
              color: Color(0xFF4ECDC4),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFF4ECDC4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
