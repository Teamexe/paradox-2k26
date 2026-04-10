import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'loader.dart'; // Import the LoaderScreen

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? userName;
  int? userScore;
  String? userEmail;
  String? profilePictureUrl;

  final storage = const FlutterSecureStorage();
  bool _isLoading = true; // Add loading state

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      // User is not logged in
      setState(() {
        _isLoading = false; // Stop loader if no token
      });
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
          profilePictureUrl = null; // Placeholder
          _isLoading = false; // Stop loader after data is loaded
        });
      } else {
        print('Error fetching profile data: ${response.statusCode}');
        _showErrorDialog('Error fetching profile data');
        setState(() {
          _isLoading = false; // Stop loader on error
        });
      }
    } catch (e) {
      print('Error: $e');
      _showErrorDialog('Network error. Please try again.');
      setState(() {
        _isLoading = false; // Stop loader on error
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? const LoaderScreen() // Use the loader from loader.dart
              : LayoutBuilder(
                builder: (context, constraints) {
                  final double screenWidth = constraints.maxWidth;
                  final double screenHeight = constraints.maxHeight;

                  // Responsive scaling function
                  double scale(double value) =>
                      value * (screenWidth / 390); // Base width

                  // Font Scaling: Clamping to reasonable values
                  double fontScale = screenWidth / 375;
                  fontScale = fontScale.clamp(0.8, 1.4);

                  return SafeArea(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        image: DecorationImage(
                          image: AssetImage('assets/images/all_bg.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05,
                          ), // Proportional padding
                          child: Column(
                            children: [
                              SizedBox(
                                height: screenHeight * 0.05,
                              ), // Spacing above paradox_text.png
                              SizedBox(
                                height: screenHeight * 0.07,
                                child: Image.asset(
                                  'assets/images/paradox_text.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(
                                height: screenHeight * 0.1,
                              ), // Increased spacing to move the container lower
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Outer Container
                                  Container(
                                    width: screenWidth * 0.9,
                                    height: screenHeight * 0.5,
                                    decoration: BoxDecoration(
                                      image: const DecorationImage(
                                        image: AssetImage(
                                          'assets/images/leaderboard_list_bg.png',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        scale(25),
                                      ),
                                    ),
                                  ),
                                  // Inner Container
                                  Container(
                                    width: screenWidth * 0.85,
                                    padding: EdgeInsets.all(screenWidth * 0.02),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF333333,
                                      ).withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(
                                        scale(20),
                                      ),
                                      image: const DecorationImage(
                                        image: AssetImage(
                                          'assets/images/profile_section.png',
                                        ),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        // Profile Image
                                        Container(
                                          width: screenWidth * 0.25,
                                          height: screenWidth * 0.25,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.grey.shade800,
                                              width: scale(3),
                                            ),
                                            color: Colors.white,
                                          ),
                                          child: ClipOval(
                                            child:
                                                profilePictureUrl != null
                                                    ? Image.network(
                                                      profilePictureUrl!,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) => const Center(
                                                            child: Text(
                                                              'Image not available',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                          ),
                                                    )
                                                    : Image.asset(
                                                      'assets/images/user_image.webp',
                                                      fit: BoxFit.cover,
                                                    ),
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.02),
                                        // Name
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 6,
                                            horizontal: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                            borderRadius: BorderRadius.circular(
                                              scale(10),
                                            ),
                                          ),
                                          child: Text(
                                            userName ?? 'Guest',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: fontScale * 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.02),
                                        // Email Box
                                        _buildInfoBox(
                                          context,
                                          icon: Icons.email,
                                          iconColor: Colors.green.shade300,
                                          value: userEmail ?? 'N/A',
                                          label: 'Email',
                                          fontSize: fontScale * 14,
                                        ),
                                        SizedBox(height: screenHeight * 0.015),
                                        // Score Box
                                        _buildInfoBox(
                                          context,
                                          icon: Icons.star,
                                          iconColor: Colors.orange.shade300,
                                          value: userScore?.toString() ?? '0',
                                          label: 'Score',
                                          fontSize: fontScale * 14,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildInfoBox(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required double fontSize,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon and Value
          Row(
            children: [
              Icon(icon, color: iconColor, size: fontSize),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Label
          Text(
            label,
            style: TextStyle(color: Colors.black, fontSize: fontSize),
          ),
        ],
      ),
    );
  }
}
