import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:paradox_2k26/theme/app_theme.dart';

class HurrayScreen extends StatefulWidget {
  final int completedLevel;

  const HurrayScreen({super.key, required this.completedLevel});

  @override
  State<HurrayScreen> createState() => _HurrayScreenState();
}

class _HurrayScreenState extends State<HurrayScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _controller.forward();
    _confettiController.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  String _getHurrayText() {
    if (widget.completedLevel == 1) {
      return 'LEVEL 1 COMPLETE\n\nLevel 2 starts soon';
    } else if (widget.completedLevel == 2) {
      return 'LEVEL 2 COMPLETE\n\nResults will be announced soon';
    } else {
      return 'LEVEL ${widget.completedLevel} COMPLETE!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle grid background
          Positioned.fill(
            child: CustomPaint(painter: _GridPainter()),
          ),

          // Confetti
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            numberOfParticles: 30,
            emissionFrequency: 0.05,
            gravity: 0.2,
            colors: const [
              AppTheme.accentCyan,
              Color(0xFFBC13FE),
              Color(0xFF39FF14),
              Color(0xFFFFD700),
              Colors.white,
            ],
          ),

          // Animated Text
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '🎉',
                        style: TextStyle(fontSize: 60),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _getHurrayText(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                          fontFamily: 'monospace',
                          shadows: [
                            Shadow(
                              color: AppTheme.accentCyan.withOpacity(0.5),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.accentCyan.withOpacity(0.5),
                            ),
                          ),
                          child: const Text(
                            'BACK TO HOME',
                            style: TextStyle(
                              color: AppTheme.accentCyan,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 0.5;

    const spacing = 40.0;
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
