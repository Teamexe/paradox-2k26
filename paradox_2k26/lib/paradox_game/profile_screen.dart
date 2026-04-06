import 'package:flutter/material.dart';
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
  String? userName;
  int? userScore;
  String? userEmail;

  final storage = const FlutterSecureStorage();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://paradox-2025.vercel.app/api/v1/home'),
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
        title: const Text('Error', style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child:
                const Text('OK', style: TextStyle(color: AppTheme.accentCyan)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoaderScreen();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // Title
              Text(
                'PROFILE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  fontFamily: 'monospace',
                  shadows: [
                    Shadow(
                      color: AppTheme.accentCyan.withOpacity(0.4),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Avatar
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppTheme.accentCyan.withOpacity(0.4), width: 2),
                  color: AppTheme.cardBlue,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentCyan.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: const Icon(Icons.person,
                    color: AppTheme.accentCyan, size: 50),
              ),
              const SizedBox(height: 20),

              // Name
              Text(
                userName ?? 'Guest',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // Info cards
              _buildInfoCard(
                icon: Icons.email_rounded,
                iconColor: AppTheme.accentCyan,
                label: 'Email',
                value: userEmail ?? 'N/A',
              ),
              const SizedBox(height: 14),
              _buildInfoCard(
                icon: Icons.star_rounded,
                iconColor: const Color(0xFFFFD700),
                label: 'Score',
                value: userScore?.toString() ?? '0',
              ),
              const SizedBox(height: 14),
              _buildInfoCard(
                icon: Icons.school_rounded,
                iconColor: const Color(0xFFBC13FE),
                label: 'Institution',
                value: 'NIT Hamirpur',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBlue,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: iconColor.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
