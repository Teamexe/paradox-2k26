import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:paradox_2k26/paradox_game/loader.dart';
import 'package:paradox_2k26/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedGender = 'male'; // Default
  final String _genderKey = 'user_gender';
  String? userName;
  int? userScore;
  String? userEmail;

  final storage = const FlutterSecureStorage();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    _loadGender();

  }
  Future<void> _loadGender() async {
    final savedGender = await storage.read(key: _genderKey);
    if (savedGender != null) {
      setState(() {
        _selectedGender = savedGender;
      });
    }
  }

  Future<void> _toggleGender() async {
    String newGender = _selectedGender == 'male' ? 'female' : 'male';
    await storage.write(key: _genderKey, value: newGender);
    setState(() {
      _selectedGender = newGender;
    });

    // Optional: Haptic feedback for a "game" feel
    HapticFeedback.lightImpact();
  }

  Future<void> _fetchProfileData() async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://paradox-2k26.onrender.com/api/v1/home'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        final data = jsonDecode(response.body);
        setState(() {
          userName = data['name'];
          userScore = data['score'] - (data['hintUsed']?.length ?? 0) * 10;
          userEmail = data['email'];
          _isLoading = false;
        });
      } else {
        _showErrorDialog('Error fetching profile data');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showErrorDialog('Network error. Please try again.');
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('System Error', style: TextStyle(color: Colors.white, fontFamily: 'monospace')),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ACKNOWLEDGE', style: TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoaderScreen();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A12),
      body: Stack(
        children: [
          // Background Glow effect


          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center ,
                    children: [

                      const Text(
                        'PROFILE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(height: 40),

                  // Profile Avatar Section
                  // Replace your Center(child: Stack(...)) section with this:
                  Center(
                    child: GestureDetector(
                      onTap: _toggleGender,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer Glow Ring
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: (_selectedGender == 'male' ? AppTheme.accentCyan : Colors.pinkAccent).withOpacity(0.2),
                                  width: 1
                              ),
                            ),
                          ),
                          // Avatar Container
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [AppTheme.cardBlue, AppTheme.bgDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (_selectedGender == 'male' ? AppTheme.accentCyan : Colors.pinkAccent).withOpacity(0.2),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                                _selectedGender == 'male' ? Icons.face_unlock_rounded : Icons.face_6_rounded,
                                color: _selectedGender == 'male' ? AppTheme.accentCyan : Colors.pinkAccent,
                                size: 50
                            ),
                          ),
                          // Small "Edit" badge
                          Positioned(
                            bottom: 5,
                            right: 5,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.sync, size: 12, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    userName?.toUpperCase() ?? 'GUEST_USER',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'NIT HAMIRPUR',
                    style: TextStyle(
                      color: AppTheme.accentCyan.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Score Highlight Box
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.cardBlue.withOpacity(0.8), AppTheme.cardBlue.withOpacity(0.4)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [

                        _buildStatItem("CURRENT SCORE", userScore?.toString() ?? '0', const Color(0xFFFFD700)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Detailed Info
                  _buildGlassTile(
                    icon: Icons.alternate_email_rounded,
                    label: "IDENTIFICATION EMAIL",
                    value: userEmail ?? 'unknown@paradox.com',
                    color: Colors.white54,
                  ),
                  const SizedBox(height: 16),


                  // Bottom Tag


                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, letterSpacing: 1)),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
        ),
      ],
    );
  }

  Widget _buildGlassTile({required IconData icon, required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 9, letterSpacing: 1.5)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w400)),
            ],
          ),
        ],
      ),
    );
  }
}