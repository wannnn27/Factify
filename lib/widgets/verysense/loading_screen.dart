import 'package:flutter/material.dart';
import '../../models/verification_result.dart';

class VerysenseLoadingScreen extends StatefulWidget {
  final ContentType contentType;
  final VoidCallback? onCancel;

  const VerysenseLoadingScreen({
    super.key,
    required this.contentType,
    this.onCancel,
  });

  @override
  State<VerysenseLoadingScreen> createState() => _VerysenseLoadingScreenState();
}

class _VerysenseLoadingScreenState extends State<VerysenseLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  int _currentStep = 0;

  final List<String> _steps = [
    'Menghubungkan ke server AI...',
    'Menganalisis konten...',
    'Mendeteksi anomali...',
    'Memverifikasi keaslian...',
    'Menyusun laporan...',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _startStepProgress();
  }

  void _startStepProgress() async {
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 2000));
      if (mounted) {
        setState(() => _currentStep = i);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getAnalysisTitle() {
    switch (widget.contentType) {
      case ContentType.text:
        return 'Menganalisis Teks';
      case ContentType.url:
        return 'Menganalisis URL';
      case ContentType.image:
        return 'Menganalisis Gambar';
      case ContentType.video:
        return 'Menganalisis Video';
    }
  }

  IconData _getContentIcon() {
    switch (widget.contentType) {
      case ContentType.text:
        return Icons.text_fields;
      case ContentType.url:
        return Icons.link;
      case ContentType.image:
        return Icons.image;
      case ContentType.video:
        return Icons.videocam;
    }
  }

  Color _getAccentColor() {
    switch (widget.contentType) {
      case ContentType.video:
        return const Color(0xFF6C5CE7);
      default:
        return const Color(0xFF4ECDC4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _getAccentColor();

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
              Color(0x0C16213E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    if (widget.onCancel != null)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: widget.onCancel,
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
                              ),
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _getAnalysisTitle(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                accentColor.withAlpha(51),
                                accentColor.withAlpha(13),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: accentColor.withAlpha(102),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withAlpha(77),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            _getContentIcon(),
                            size: 60,
                            color: accentColor,
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),

                      SizedBox(
                        width: 200,
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.white10,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(accentColor),
                          minHeight: 4,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      const SizedBox(height: 24),

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _steps[_currentStep],
                          key: ValueKey(_currentStep),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 48),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_steps.length, (index) {
                          final isActive = index <= _currentStep;
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive ? accentColor : Colors.white24,
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 48),

                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: accentColor.withAlpha(26),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: accentColor.withAlpha(77),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: accentColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'AI sedang menganalisis konten Anda dengan teknologi machine learning terkini',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
}
