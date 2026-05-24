import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  Timer? _navigationTimer;

  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _ringScale;
  late Animation<double> _textSlide;
  late Animation<double> _textOpacity;
  late Animation<double> _taglineOpacity;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startNavigationTimer();
  }

  void _initAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    )..repeat();

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.35, curve: Curves.elasticOut),
      ),
    );

    _logoRotation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    _ringScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.15, 0.45, curve: Curves.easeOutBack),
      ),
    );

    _textSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.35, 0.55, curve: Curves.easeOut),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.35, 0.55, curve: Curves.easeOut),
      ),
    );

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.50, 0.70, curve: Curves.easeOut),
      ),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.55, 1.0, curve: Curves.easeInOut),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _mainController.forward();
  }

  void _startNavigationTimer() {
    _navigationTimer = Timer(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const OnboardingScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _mainController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E21),
              Color(0xFF0D1B2A),
              Color(0xFF1B263B),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Floating orbs background
            ...List.generate(4, (index) => _buildFloatingOrb(index)),

            // Grid pattern overlay
            CustomPaint(
              size: Size.infinite,
              painter: GridPatternPainter(),
            ),

            // Main content - SafeArea with proper layout
            SafeArea(
              child: AnimatedBuilder(
                animation: Listenable.merge(
                    [_mainController, _pulseController, _rotateController]),
                builder: (context, child) {
                  return Column(
                    children: [
                      // Top spacer
                      const Spacer(flex: 2),

                      // Logo section
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer rotating ring
                            Transform.scale(
                              scale: _ringScale.value,
                              child: Transform.rotate(
                                angle: _rotateController.value * 2 * math.pi,
                                child: Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF4ECDC4)
                                          .withValues(alpha: 0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: CustomPaint(
                                    painter: DashedCirclePainter(
                                      color: const Color(0xFF4ECDC4),
                                      dashCount: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Middle pulsing ring
                            Transform.scale(
                              scale: _ringScale.value * _pulseAnimation.value,
                              child: Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF6C5CE7)
                                        .withValues(alpha: 0.2),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),

                            // Glow effect
                            Transform.scale(
                              scale: _logoScale.value * _pulseAnimation.value,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF4ECDC4)
                                          .withValues(alpha: 0.4),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Main logo
                            Transform.scale(
                              scale: _logoScale.value,
                              child: Transform.rotate(
                                angle: _logoRotation.value,
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF4ECDC4),
                                        Color(0xFF44A08D),
                                        Color(0xFF6C5CE7),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF4ECDC4)
                                            .withValues(alpha: 0.5),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.verified_user_rounded,
                                      size: 44,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // App Name
                      Transform.translate(
                        offset: Offset(0, _textSlide.value),
                        child: Opacity(
                          opacity: _textOpacity.value,
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Colors.white,
                                Color(0xFF4ECDC4),
                                Colors.white,
                              ],
                            ).createShader(bounds),
                            child: const Text(
                              "FACTIFY",
                              style: TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 10,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Tagline badge
                      Opacity(
                        opacity: _taglineOpacity.value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
                              width: 1,
                            ),
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF4ECDC4).withValues(alpha: 0.1),
                                const Color(0xFF6C5CE7).withValues(alpha: 0.05),
                              ],
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF4ECDC4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF4ECDC4)
                                          .withValues(alpha: 0.5),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Literasi Digital Indonesia",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Middle spacer
                      const Spacer(flex: 2),

                      // Feature pills
                      Opacity(
                        opacity: _progressAnimation.value,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildFeaturePill(Icons.fact_check, "Cek Fakta"),
                            const SizedBox(width: 10),
                            _buildFeaturePill(Icons.psychology, "AI Verify"),
                            const SizedBox(width: 10),
                            _buildFeaturePill(Icons.school, "Edukasi"),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Progress bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: _progressAnimation.value,
                                  child: Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF4ECDC4),
                                          Color(0xFF6C5CE7),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF4ECDC4)
                                              .withValues(alpha: 0.5),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 10,
                                  height: 10,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Mempersiapkan pengalaman terbaik...",
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 11,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Version
                      Text(
                        "v1.0.0",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.2),
                          fontSize: 10,
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingOrb(int index) {
    final positions = [
      const Offset(-60, 80),
      const Offset(280, 120),
      const Offset(-40, 500),
      const Offset(300, 600),
    ];

    final sizes = [140.0, 120.0, 160.0, 100.0];
    final colors = [
      const Color(0xFF4ECDC4),
      const Color(0xFF6C5CE7),
      const Color(0xFFFFD93D),
      const Color(0xFFFF6B6B),
    ];

    return Positioned(
      left: positions[index].dx,
      top: positions[index].dy,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Transform.scale(
            scale:
                1 + (_pulseController.value * 0.08 * (index % 2 == 0 ? 1 : -1)),
            child: Container(
              width: sizes[index],
              height: sizes[index],
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colors[index].withValues(alpha: 0.12),
                    colors[index].withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturePill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF4ECDC4)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for grid pattern
class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..strokeWidth = 0.5;

    const spacing = 50.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for dashed circle
class DashedCirclePainter extends CustomPainter {
  final Color color;
  final int dashCount;

  DashedCirclePainter({required this.color, this.dashCount = 8});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 10;

    final dashAngle = (2 * math.pi) / (dashCount * 2);

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle * 2;
      final endAngle = startAngle + dashAngle;

      final startX = center.dx + radius * math.cos(startAngle);
      final startY = center.dy + radius * math.sin(startAngle);
      final endX = center.dx + radius * math.cos(endAngle);
      final endY = center.dy + radius * math.sin(endAngle);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
