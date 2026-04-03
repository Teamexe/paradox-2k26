import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:paradox_25/screens/auth_choice_screen.dart';
import 'package:paradox_25/screens/splash_screen.dart';
import 'package:paradox_25/screens/level_complete_screen.dart'; // Import Hurray Screen
import 'question_screen.dart';
import 'level2_question_screen.dart'; // Import Level2QuestionScreen
import './sign_in_screen.dart';
import './prizes_screen.dart';
import './leaderboard_screen.dart';
import './rules_screen.dart';
import './profile_screen.dart';
import 'package:paradox_25/widgets/bottom_navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userName;
  int? userScore;
  int _currentLevel = 1; // Default to level 1

  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkAuthAndFetchData();
  }

  Future<void> _checkAuthAndFetchData() async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthScreen()),
      );
      return;
    }

    try {
      // Fetch home data
      final homeResponse = await http.get(
        Uri.parse('https://paradox-2025.vercel.app/api/v1/home'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (homeResponse.statusCode == 200 || homeResponse.statusCode == 202) {
        final homeData = jsonDecode(homeResponse.body);
        setState(() {
          userName = homeData['name'];
          userScore = homeData['score'];
        });
      } else if (homeResponse.statusCode == 401) {
        await storage.delete(key: 'authToken');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
        );
        return; // Return to prevent further execution
      } else {
        print('Error fetching user home data: ${homeResponse.statusCode}');
        _showErrorDialog('Error fetching user data');
        return; // Return to prevent further execution
      }

      // Fetch current level
      final levelResponse = await http.get(
        Uri.parse('https://paradox-2025.vercel.app/api/v1/currentLevel'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (levelResponse.statusCode == 200 || levelResponse.statusCode == 202) {
        final levelData = jsonDecode(levelResponse.body);
        if (levelData['success'] == true) {
          setState(() {
            _currentLevel = levelData['data'];
          });
        } else {
          print('Error fetching current level: ${levelData['message']}');
          _showErrorDialog(
            'Error fetching current level: ${levelData['message']}',
          );
          return;
        }
      } else {
        print('Error fetching current level: ${levelResponse.statusCode}');
        _showErrorDialog(
          'Error fetching current level (Status: ${levelResponse.statusCode})',
        );
        return; // Return to prevent further execution
      }
    } catch (e) {
      print('Error: $e');
      _showErrorDialog('Network error. Please try again.');
      return; // Return to prevent further execution
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

  void _showLevelLockedDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Level 2 Locked'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Level 2 is currently locked.'),
                SizedBox(height: 8),
                Text(
                  'Top 50 participants of Level 1 will commence to Level 2 tomorrow.',
                ),
                SizedBox(height: 8),
                Text(
                  'Level 2 will officially start on **April 12th**. Stay tuned!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showLevel1CompletedDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Level 1 Completed'),
            content: const Text('You have already completed Level 1.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _navigateToQuestionScreen(int level) {
    Widget nextScreen;
    if (level == 2) {
      nextScreen = Level2QuestionScreen(
        level: level,
        onLevelComplete: () {
          // After completing Level 2, re-fetch the current level
          _checkAuthAndFetchData();
          // Optionally navigate to a different screen after Level 2 completion
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HurrayScreen(completedLevel: 2),
            ),
          );
        },
      );
    } else {
      nextScreen = QuestionScreen(
        level: level,
        onLevelComplete: () {
          // After completing Level 1, re-fetch the current level
          _checkAuthAndFetchData();
        },
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double screenWidth = constraints.maxWidth;
          final double screenHeight = constraints.maxHeight;

          // Responsive scaling function
          double scale(double value) => value * (screenWidth / 390);

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/all_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.07),
                // Paradox logo
                SizedBox(
                  height: screenHeight * 0.07,
                  child: Image.asset(
                    'assets/images/paradox_text.png',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                Center(
                  child: Container(
                    height: screenHeight * 0.6,
                    width: screenWidth * 0.85,
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage(
                          'assets/images/leaderboard_list_bg.png',
                        ),
                        fit: BoxFit.fill,
                      ),
                      borderRadius: BorderRadius.circular(scale(20)),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // "Let's Begin" with Nimbus and EXE logos
                        Positioned(
                          top: screenHeight * 0.035,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/exe_logo1.png',
                                height: scale(32),
                                width: scale(32),
                                fit: BoxFit.contain,
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Text(
                                "Let's Begin",
                                style: TextStyle(
                                  fontFamily: 'PixelFont',
                                  fontSize: scale(21),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Image.asset(
                                'assets/images/Nimbus_white_logo.png',
                                height: scale(32),
                                width: scale(32),
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ),

                        // Profile Section
                        Positioned(
                          top: screenHeight * 0.09,
                          child: Container(
                            height: screenHeight * 0.45,
                            width: screenWidth * 0.8,
                            decoration: BoxDecoration(
                              image: const DecorationImage(
                                image: AssetImage(
                                  'assets/images/profile_section.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(scale(15)),
                            ),
                          ),
                        ),

                        // Level 1 Button
                        Positioned(
                          top: screenHeight * 0.22,
                          child: Container(
                            width: screenWidth * 0.55,
                            height: screenHeight * 0.08,
                            decoration: BoxDecoration(
                              image: const DecorationImage(
                                image: AssetImage(
                                  'assets/images/level_image.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(scale(10)),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                if (_currentLevel > 1) {
                                  _showLevel1CompletedDialog();
                                } else if (_currentLevel == 1) {
                                  _navigateToQuestionScreen(1);
                                } else {
                                  // This case shouldn't ideally happen
                                  _showErrorDialog(
                                    "Level 1 is not yet available.",
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: Text(
                                'Level 1',
                                style: TextStyle(
                                  fontSize: scale(35),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontFamily: 'RaviPrakash',
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Level 2 Button
                        Positioned(
                          top: screenHeight * 0.33,
                          child: Container(
                            width: screenWidth * 0.55,
                            height: screenHeight * 0.08,
                            decoration: BoxDecoration(
                              image: const DecorationImage(
                                image: AssetImage(
                                  'assets/images/level_image.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(scale(10)),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                if (_currentLevel >= 2) {
                                  _navigateToQuestionScreen(2);
                                } else if (_currentLevel == 1) {
                                  _showLevelLockedDialog();
                                } else {
                                  _showErrorDialog(
                                    "Level 2 is not yet available.",
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: Text(
                                'Level 2',
                                style: TextStyle(
                                  fontSize: scale(35),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontFamily: 'RaviPrakash',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
