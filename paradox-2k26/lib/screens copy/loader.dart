import 'package:flutter/material.dart';
import 'dart:math';

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
      duration: const Duration(milliseconds: 800), // Fast animation
    )..repeat(); // Repeats the animation indefinitely
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: DottedLoaderPainter(animationValue: _controller.value),
              size: const Size(50, 50), // Small loader size
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
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color.fromARGB(255, 37, 3, 3),
          Colors.purple,
          Colors.red,
          const Color.fromARGB(255, 255, 0, 166),
          const Color.fromARGB(200, 195, 28, 189),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final double radius = size.width * 0.4; // Radius of the circle
    final Offset center = Offset(size.width / 2, size.height / 2);
    final int dotCount = 12; // Number of dots
    final double dotRadius = size.width * 0.05; // Size of each dot

    for (int i = 0; i < dotCount; i++) {
      final double angle = (2 * pi / dotCount) * i - (2 * pi * animationValue);
      final double dx = center.dx + radius * cos(angle);
      final double dy = center.dy + radius * sin(angle);

      // Adjust opacity for trailing dots
      final double opacity = (1 - (i / dotCount)).clamp(0.3, 1.0);

      canvas.drawCircle(
        Offset(dx, dy),
        dotRadius,
        paint..color = paint.color.withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Repaint on every animation frame
  }
}