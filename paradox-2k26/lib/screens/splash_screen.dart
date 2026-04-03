import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:paradox/main.dart';
import 'package:paradox/paradox_game/auth_choice_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _glitchController;
  late AnimationController _scanController;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Console logs for hacker feel
  final List<String> _logs = [
    "INITIALIZING SYSTEM...",
    "BYPASSING FIREWALL...",
    "DECRYPTING CORE NODES...",
    "ACCESS GRANTED.",
  ];
  int _currentLogIndex = 0;
  Timer? _logTimer;

  @override
  void initState() {
    super.initState();

    // Main Entrance (0 to 1)
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    // Rapid Glitch Jitter
    _glitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..repeat(reverse: true);

    // Scanline movement
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Typewriter effect for logs
    _logTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (_currentLogIndex < _logs.length - 1) {
        setState(() => _currentLogIndex++);
      } else {
        timer.cancel();
      }
    });

    // Navigation with auth check
    Future.delayed(const Duration(milliseconds: 3500), () async {
      if (!mounted) return;

      final token = await _storage.read(key: 'authToken');
      final Widget destination =
          token != null ? const MainScreen() : const AuthScreen();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, anim, _) => destination,
            transitionsBuilder: (context, anim, _, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _glitchController.dispose();
    _scanController.dispose();
    _logTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050A18), // Deeper Midnight
      body: Stack(
        children: [
          _buildGridBackground(),
          _buildScanline(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGlitchLogo(),
                const SizedBox(height: 40),
                _buildAnimatedTitle(),
                const SizedBox(height: 10),
                _buildHackerLogs(),
              ],
            ),
          ),
          _buildBottomLoading(),
        ],
      ),
    );
  }

  // 1. Grid Background with moving perspective
  Widget _buildGridBackground() {
    return Opacity(
      opacity: 0.1,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://www.transparenttextures.com/patterns/carbon-fibre.png',
            ),
            repeat: ImageRepeat.repeat,
          ),
        ),
      ),
    );
  }

  // 2. The Logo with Chromatic Aberration (RGB Shift Glitch)
  Widget _buildGlitchLogo() {
    return AnimatedBuilder(
      animation: _glitchController,
      builder: (context, child) {
        // Random offset for glitch
        double offset = _glitchController.value * 2.0;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Cyan Layer Shift
            Transform.translate(
              offset: Offset(-offset, offset),
              child: Opacity(
                opacity: 0.5,
                child: _logoImage(const Color(0xFF00C6FF)),
              ),
            ),
            // Magenta Layer Shift
            Transform.translate(
              offset: Offset(offset, -offset),
              child: Opacity(
                opacity: 0.5,
                child: _logoImage(const Color(0xFFBC13FE)),
              ),
            ),
            // Main Logo
            _logoImage(null),
          ],
        );
      },
    );
  }

  Widget _logoImage(Color? colorFilter) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: Color(0xFF020915),
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: const AssetImage('assets/images/logo.png'),
          fit: BoxFit.contain,
          colorFilter: colorFilter != null
              ? ColorFilter.mode(colorFilter, BlendMode.screen)
              : null,
        ),
      ),
    );
  }

  // 3. Title with Typewriter/Flicker
  Widget _buildAnimatedTitle() {
    return FadeTransition(
      opacity: _mainController,
      child: Column(
        children: [
          Text(
            'ParaDoTexe',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
              fontFamily: 'monospace',
              shadows: [
                Shadow(
                  color: const Color(0xFF00C6FF).withOpacity(0.5),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "Pre-Paradox",
            style: TextStyle(
              color: Color(0xFF580DF1),
              fontSize: 20,
              letterSpacing: 4,
            ),
          ),
        ],
      ),
    );
  }

  // 4. Hacker Console Logs
  Widget _buildHackerLogs() {
    return Container(
      height: 20,
      alignment: Alignment.center,
      child: Text(
        _logs[_currentLogIndex],
        style: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontSize: 10,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  // 5. Vertical Scanning Beam
  Widget _buildScanline() {
    return AnimatedBuilder(
      animation: _scanController,
      builder: (context, child) {
        return Positioned(
          top: _scanController.value * MediaQuery.of(context).size.height,
          left: 0,
          right: 0,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00C6FF).withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFF00C6FF).withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 6. Modern Bottom Progress
  Widget _buildBottomLoading() {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Center(
        child: Column(
          children: [
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white10,
                color: const Color(0xFF00C6FF),
                minHeight: 1,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "LOAD: 88%",
              style: TextStyle(color: Colors.white24, fontSize: 8),
            ),
          ],
        ),
      ),
    );
  }
}
