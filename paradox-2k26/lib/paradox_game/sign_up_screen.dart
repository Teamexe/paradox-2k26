import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:paradox_2k26/main.dart';
import 'package:paradox_2k26/paradox_game/sign_in_screen.dart';
import 'package:paradox_2k26/theme/app_theme.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  bool showOtpField = false;
  final storage = const FlutterSecureStorage();

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _sendOTP() async {
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _nameError = name.isEmpty ? 'Name cannot be empty' : null;
      _emailError =
          _validateCollegeEmail(email) ? null : 'Please enter your college email ID';
      _passwordError = password.isEmpty || password.length < 6
          ? 'Password must be at least 6 characters'
          : null;
    });

    if (_nameError != null || _emailError != null || _passwordError != null) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://paradox-2025.vercel.app/api/v1/auth/signup/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        setState(() => showOtpField = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Please check your spam folder for the OTP email.'),
              backgroundColor: AppTheme.cardBlue,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else if (response.statusCode == 409) {
        _showErrorDialog('Email is already in use. Please use a different email.');
      } else {
        String errorMessage = 'Error sending OTP';
        if (response.body.isNotEmpty) {
          try {
            final errorData = jsonDecode(response.body);
            if (errorData['message'] != null) errorMessage = errorData['message'];
          } catch (_) {}
        }
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      _showErrorDialog('Network error. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final otp = _otpController.text.trim();

    if (!_validateCollegeEmail(email)) {
      _showErrorDialog('Please enter your college email ID.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://paradox-2025.vercel.app/api/v1/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['data']['token'];
        if (token != null) {
          await storage.write(key: 'authToken', value: token);
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          }
        } else {
          _showErrorDialog('Token not found in response');
        }
      } else if (response.statusCode == 409) {
        _showErrorDialog('Email is already in use. Please use a different email.');
      } else {
        String errorMessage = 'Signup failed. Please check your details.';
        if (response.body.isNotEmpty) {
          try {
            final errorData = jsonDecode(response.body);
            if (errorData['message'] != null) errorMessage = errorData['message'];
          } catch (_) {}
        }
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      _showErrorDialog('Network error. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _validateCollegeEmail(String email) {
    final regex = RegExp(r'^\d{2}[a-zA-Z]{3}\d{3}@nith\.ac\.in$');
    return regex.hasMatch(email);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBlue,
        title: const Text('Error', style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: AppTheme.accentCyan)),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label,
      {Widget? suffixIcon, String? errorText}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
      filled: true,
      fillColor: AppTheme.cardBlue,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.accentCyan.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.accentCyan.withOpacity(0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.accentCyan, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.withOpacity(0.6)),
      ),
      errorText: errorText,
      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white54),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              'SIGN UP',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                fontFamily: 'monospace',
                shadows: [
                  Shadow(
                    color: AppTheme.accentCyan.withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your account',
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
            ),
            const SizedBox(height: 35),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Name', errorText: _nameError),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Email', errorText: _emailError),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                'Password',
                errorText: _passwordError,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white38,
                  ),
                  onPressed: () {
                    setState(() => _isPasswordVisible = !_isPasswordVisible);
                  },
                ),
              ),
            ),
            const SizedBox(height: 25),
            if (showOtpField) ...[
              TextField(
                controller: _otpController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Enter OTP'),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentCyan,
                    foregroundColor: AppTheme.bgDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppTheme.bgDark,
                          ),
                        )
                      : const Text(
                          'VERIFY',
                          style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2,
                          ),
                        ),
                ),
              ),
            ] else
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentCyan,
                    foregroundColor: AppTheme.bgDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppTheme.bgDark,
                          ),
                        )
                      : const Text(
                          'GET OTP',
                          style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2,
                          ),
                        ),
                ),
              ),
            const SizedBox(height: 25),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              },
              child: RichText(
                text: TextSpan(
                  text: "Already have an account? ",
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
                  children: const [
                    TextSpan(
                      text: "Sign In",
                      style: TextStyle(
                        color: AppTheme.accentCyan,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
