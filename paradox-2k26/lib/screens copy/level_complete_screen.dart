import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

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

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

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
      return 'Hurray 🎉! You have completed Level 1,\nLevel 2 starts on 12th April';
    } else if (widget.completedLevel == 2) {
      return 'Hurray 🎉! You have completed Level 2.\nResults will be announced soon';
    } else {
      return 'Hurray 🎉! Level ${widget.completedLevel} completed!'; // Default case
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double fontSize = screenSize.width * 0.06; // Responsive font size
    final String hurrayText = _getHurrayText();

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset('assets/images/all_bg.png', fit: BoxFit.cover),
          ),

          // Paradox Text Image at the Top
          Positioned(
            top: screenSize.height * 0.08,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/paradox_text.png',
              height: screenSize.height * 0.1,
            ),
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
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
          ),

          // Centered Animated Text
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    hurrayText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize.clamp(18, 30),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
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
