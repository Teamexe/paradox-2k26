import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './auth_choice_screen.dart';
import './home_screen.dart';
import 'package:paradox_25/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await storage.read(key: 'authToken');

    if (token != null) {
      // Token exists, validate it (strongly recommended)
      // If the token is invalid, navigate to AuthScreen.
      // If valid, navigate to HomeScreen.

      // Example of (simplified) token validation (replace with your actual API call):
      try {
        final response = await http.get(
          Uri.parse(
            'https://paradox-2025.vercel.app/api/v1/home',
          ), // Replace with your token validation endpoint
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          // Token is valid, navigate to HomeScreen
          print('Token is valid, navigating to HomeScreen');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          // Token is invalid, navigate to AuthScreen
          print('Token is invalid, navigating to AuthScreen');
          await storage.delete(key: 'authToken'); // Clear the invalid token
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AuthScreen(),
            ), // Navigate to AuthScreen
          );
        }
      } catch (e) {
        // Network error or other validation error, navigate to AuthScreen
        print('Token validation error: $e, navigating to AuthScreen');
        await storage.delete(key: 'authToken'); // Clear the invalid token
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AuthScreen(),
          ), // Navigate to AuthScreen
        );
      }
    } else {
      // No token, navigate to AuthScreen
      print('No token found, navigating to AuthScreen');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthScreen(),
        ), // Navigate to AuthScreen
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double screenWidth = constraints.maxWidth;
          final double screenHeight = constraints.maxHeight;

          // Responsive scaling function
          double scale(double value) =>
              value * (screenWidth / 390); // Base width

          return Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.asset(
                  'assets/images/paradox_logo.png',
                  fit: BoxFit.fill,
                ),
              ),
              // Content
              Center(
                child: SingleChildScrollView(
                  child: Transform.translate(
                    offset: Offset(
                      0,
                      screenHeight * 0.1,
                    ), // Proportional vertical offset
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Removed Paradox Logo (if it's not needed in splash)

                        // Paradox Text
                        SizedBox(
                          height: scale(80), // Scaled height
                          child: Image.asset('assets/images/paradox_logo.png'),
                        ),
                        SizedBox(
                          height: screenHeight * 0.15,
                        ), // Proportional Spacing
                        // Removed Sign In Button (Navigation is handled in _checkAuth)
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
