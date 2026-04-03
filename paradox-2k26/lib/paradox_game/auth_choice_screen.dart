import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:paradox/paradox_game/sign_in_screen.dart';
import 'package:paradox/paradox_game/sign_up_screen.dart';
import 'package:paradox/main.dart';
import 'package:paradox/theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isLoggedIn = false;
  bool _isLoading = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final token = await _storage.read(key: 'authToken');
    setState(() {
      _isLoggedIn = token != null;
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBlue,
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text('Do you want to logout?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child:
                const Text('No', style: TextStyle(color: AppTheme.accentCyan)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes',
                style: TextStyle(color: AppTheme.accentCyan)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await _storage.delete(key: 'authToken');
      setState(() => _isLoggedIn = false);
    }
  }

  Future<void> _handleSignIn() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
    await _checkLoginStatus();
  }

  Future<void> _handleSignUp() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
    await _checkLoginStatus();
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) SystemNavigator.pop();
      },
      child: _isLoading
          ? Scaffold(
              backgroundColor: AppTheme.bgDark,
              body: const Center(
                child: CircularProgressIndicator(color: AppTheme.accentCyan),
              ),
            )
          : Scaffold(
              backgroundColor: AppTheme.bgDark,
              body: Stack(
                children: [
                  // Subtle grid background
                  Positioned.fill(
                    child: CustomPaint(painter: _GridPainter()),
                  ),
                  // Top-right logout button
                  if (_isLoggedIn)
                    Positioned(
                      top: 50,
                      right: 20,
                      child: IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white54),
                        onPressed: _logout,
                      ),
                    ),
                  // Main content
                  Center(
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 80),
                            // Glitch-style logo
                            _buildLogo(),
                            const SizedBox(height: 16),
                            Text(
                              'PARADOX',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 8,
                                fontFamily: 'monospace',
                                shadows: [
                                  Shadow(
                                    color:
                                        AppTheme.accentCyan.withOpacity(0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '2K26',
                              style: TextStyle(
                                color: Color(0xFFBC13FE),
                                fontSize: 16,
                                letterSpacing: 6,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(height: 50),
                            if (_isLoggedIn)
                              _buildCyberButton('ENTER', _goToHome)
                            else ...[
                              _buildCyberButton('SIGN IN', _handleSignIn),
                              const SizedBox(height: 20),
                              _buildCyberButton('SIGN UP', _handleSignUp),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppTheme.cardBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accentCyan.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentCyan.withOpacity(0.15),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
        image: const DecorationImage(
          image: AssetImage('assets/images/logo.png'),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildCyberButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppTheme.accentCyan.withOpacity(0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentCyan.withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: AppTheme.accentCyan,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }
}

// Subtle background grid painter
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
