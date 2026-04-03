import 'package:flutter/material.dart';
import 'dart:math';
import 'package:paradox/theme/app_theme.dart';

class LoaderScreen extends StatefulWidget {
  const LoaderScreen({super.key});

  @override
  State<LoaderScreen> createState() => _LoaderScreenState();
}

class _LoaderScreenState extends State<LoaderScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: DottedLoaderPainter(animationValue: _controller.value),
              size: const Size(50, 50),
            );
          },
        ),
      ),
    );
  }
}

class DottedLoaderPainter extends CustomPainter {
  final double animationValue;

  DottedLoaderPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width * 0.4;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final int dotCount = 12;
    final double dotRadius = size.width * 0.05;

    for (int i = 0; i < dotCount; i++) {
      final double angle = (2 * pi / dotCount) * i - (2 * pi * animationValue);
      final double dx = center.dx + radius * cos(angle);
      final double dy = center.dy + radius * sin(angle);

      final double opacity = (1 - (i / dotCount)).clamp(0.3, 1.0);
      final double t = i / dotCount;

      // Cyan → Magenta gradient
      final color = Color.lerp(
        AppTheme.accentCyan,
        const Color(0xFFBC13FE),
        t,
      )!.withOpacity(opacity);

      canvas.drawCircle(
        Offset(dx, dy),
        dotRadius,
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
