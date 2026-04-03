import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import './sign_in_screen.dart';
import './sign_up_screen.dart';
import '../main.dart'; // Import MainScreen

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
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
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Do you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // No
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // Yes
                child: const Text('Yes'),
              ),
            ],
          ),
    );

    if (shouldLogout == true) {
      await _storage.delete(key: 'authToken'); // Clear the stored token
      setState(() {
        _isLoggedIn = false;
      });
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MainScreen(),
      ), // Navigate to MainScreen
    ).then((_) {
      _checkLoginStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child:
          _isLoading
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : Scaffold(
                body: LayoutBuilder(
                  builder: (context, constraints) {
                    final double screenWidth = constraints.maxWidth;
                    final double screenHeight = constraints.maxHeight;
                    double scale(double value) => value * (screenWidth / 390);
                    double fontScale = screenWidth / 375;
                    fontScale = fontScale.clamp(0.8, 1.4);

                    return Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/first.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (_isLoggedIn)
                          Positioned(
                            top: 40,
                            right: 20,
                            child: IconButton(
                              icon: const Icon(
                                Icons.logout,
                                color: Colors.white,
                              ),
                              onPressed: _logout,
                            ),
                          ),
                        Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(height: screenHeight * 0.2),
                                SizedBox(
                                  height: scale(80),
                                  child: Image.asset(
                                    'assets/images/paradox_text.png',
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.05),
                                if (_isLoggedIn)
                                  GestureDetector(
                                    onTap: _goToHome,
                                    child: Container(
                                      width: screenWidth * 0.65, // Button width
                                      padding: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.02,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors
                                                .transparent, // Transparent background
                                        borderRadius: BorderRadius.circular(
                                          scale(30),
                                        ), // Rounded corners
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ), // Optional border
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Enter',
                                          style: const TextStyle(
                                            fontFamily:
                                                'RaviPrakash', // Custom font
                                            fontSize: 24, // Font size
                                            color: Colors.white, // Text color
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                else ...[
                                  GestureDetector(
                                    onTap: _handleSignIn,
                                    child: Container(
                                      width: screenWidth * 0.65, // Button width
                                      padding: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.02,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors
                                                .transparent, // Transparent background
                                        borderRadius: BorderRadius.circular(
                                          scale(30),
                                        ), // Rounded corners
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ), // Optional border
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Sign In',
                                          style: const TextStyle(
                                            fontFamily:
                                                'RaviPrakash', // Custom font
                                            fontSize: 24, // Font size
                                            color: Colors.white, // Text color
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.04),
                                  GestureDetector(
                                    onTap: _handleSignUp,
                                    child: Container(
                                      width: screenWidth * 0.65, // Button width
                                      padding: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.02,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors
                                                .transparent, // Transparent background
                                        borderRadius: BorderRadius.circular(
                                          scale(30),
                                        ), // Rounded corners
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ), // Optional border
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Sign Up',
                                          style: const TextStyle(
                                            fontFamily:
                                                'RaviPrakash', // Custom font
                                            fontSize: 24, // Font size
                                            color: Colors.white, // Text color
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
    );
  }
}
