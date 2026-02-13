import 'package:flutter/material.dart';
import 'package:paradox/commit-game/constants.dart';
import 'package:paradox/screens/main_menu_screen.dart';
import 'package:paradox/services/firebase_service.dart';

class CommitClashApp extends StatefulWidget {
  const CommitClashApp({super.key});

  @override
  State<CommitClashApp> createState() => _CommitClashAppState();
}

class _CommitClashAppState extends State<CommitClashApp> {
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initFirebase();
  }

  Future<void> _initFirebase() async {
    try {
      await FirebaseService().initialize();
      if (mounted) setState(() => _initialized = true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D1117),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Color(0xFFf78166), size: 48),
              const SizedBox(height: 16),
              Text(
                'Failed to initialize',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: const Color(0xFF8B949E), fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_initialized) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D1117),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 32, height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: commitLevel4,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(color: const Color(0xFF8B949E), fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return const MainMenuScreen();
  }
}
