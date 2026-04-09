// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:paradox_2k26/paradox_game/auth_choice_screen.dart';
// import 'package:paradox_2k26/paradox_game/level_complete_screen.dart';
// import 'package:paradox_2k26/paradox_game/question_screen.dart';
// import 'package:paradox_2k26/paradox_game/level2_question_screen.dart';
// import 'package:paradox_2k26/paradox_game/sign_in_screen.dart';
// import 'package:paradox_2k26/screens/homescreen.dart';
// import 'package:paradox_2k26/theme/app_theme.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
//   String? userName;
//   int? userScore;
//   int _currentLevel = 1;
//   final storage = const FlutterSecureStorage();
//   late AnimationController _pulseController;
//   late Animation<double> _pulseAnim;
//
//   @override
//   void initState() {
//     super.initState();
//     _pulseController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 2000),
//     )..repeat(reverse: true);
//     _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );
//     _checkAuthAndFetchData();
//   }
//
//   @override
//   void dispose() {
//     _pulseController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _checkAuthAndFetchData() async {
//     final token = await storage.read(key: 'authToken');
//     if (token == null) {
//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const AuthScreen()),
//         );
//       }
//       return;
//     }
//
//     try {
//       final homeResponse = await http.get(
//         Uri.parse('https://paradox-2k26.onrender.com/'),
//         headers: {'Authorization': 'Bearer $token'},
//       );
//
//       if (homeResponse.statusCode == 200 || homeResponse.statusCode == 202) {
//         final homeData = jsonDecode(homeResponse.body);
//         setState(() {
//           userName = homeData['name'];
//           userScore = homeData['score'];
//         });
//       } else if (homeResponse.statusCode == 401) {
//         await storage.delete(key: 'authToken');
//         if (mounted) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => const SignInScreen()),
//           );
//         }
//         return;
//       } else {
//         _showErrorDialog('Error fetching user data');
//         return;
//       }
//
//       final levelResponse = await http.get(
//         Uri.parse('https://paradox-2025.vercel.app/api/v1/currentLevel'),
//         headers: {'Authorization': 'Bearer $token'},
//       );
//
//       if (levelResponse.statusCode == 200 || levelResponse.statusCode == 202) {
//         final levelData = jsonDecode(levelResponse.body);
//         if (levelData['success'] == true) {
//           setState(() => _currentLevel = levelData['data']);
//         } else {
//           _showErrorDialog('Error fetching current level: ${levelData['message']}');
//         }
//       } else {
//         _showErrorDialog('Error fetching current level');
//       }
//     } catch (e) {
//       _showErrorDialog('Network error. Please try again.');
//     }
//   }
//
//   void _showErrorDialog(String message) {
//     if (!mounted) return;
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: AppTheme.cardBlue,
//         title: const Text('Error', style: TextStyle(color: Colors.white)),
//         content: Text(message, style: const TextStyle(color: Colors.white70)),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('OK', style: TextStyle(color: AppTheme.accentCyan)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showLevelLockedDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: AppTheme.cardBlue,
//         title: const Text('Level 2 Locked',
//             style: TextStyle(color: Colors.white)),
//         content: const Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Level 2 is currently locked.',
//                 style: TextStyle(color: Colors.white70)),
//             SizedBox(height: 8),
//             Text('Top 50 participants of Level 1 will advance to Level 2.',
//                 style: TextStyle(color: Colors.white70)),
//             SizedBox(height: 8),
//             Text('Level 2 starts on April 12th. Stay tuned!',
//                 style: TextStyle(
//                     color: AppTheme.accentCyan, fontWeight: FontWeight.bold)),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('OK', style: TextStyle(color: AppTheme.accentCyan)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showLevel1CompletedDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: AppTheme.cardBlue,
//         title: const Text('Level 1 Completed',
//             style: TextStyle(color: Colors.white)),
//         content: const Text('You have already completed Level 1.',
//             style: TextStyle(color: Colors.white70)),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('OK', style: TextStyle(color: AppTheme.accentCyan)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _navigateToQuestionScreen(int level) {
//     Widget nextScreen;
//     if (level == 2) {
//       nextScreen = Level2QuestionScreen(
//         level: level,
//         onLevelComplete: () {
//           _checkAuthAndFetchData();
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const HurrayScreen(completedLevel: 2),
//             ),
//           );
//         },
//       );
//     } else {
//       nextScreen = QuestionScreen(
//         level: level,
//         onLevelComplete: () => _checkAuthAndFetchData(),
//       );
//     }
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => nextScreen),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.bgDark,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               // Title Section
//               const SizedBox(height: 10),
//               Text(
//                 'PARADOX',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 6,
//                   fontFamily: 'monospace',
//                   shadows: [
//                     Shadow(
//                       color: AppTheme.accentCyan.withOpacity(0.4),
//                       blurRadius: 12,
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 "Let's Begin",
//                 style: TextStyle(
//                   color: Colors.white.withOpacity(0.5),
//                   fontSize: 14,
//                   letterSpacing: 2,
//                 ),
//               ),
//
//               const SizedBox(height: 30),
//
//               // Welcome Card
//               if (userName != null)
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: AppTheme.cardBlue,
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                       color: AppTheme.accentCyan.withOpacity(0.15),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 48,
//                         height: 48,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           border: Border.all(
//                             color: AppTheme.accentCyan.withOpacity(0.4),
//                           ),
//                           color: AppTheme.bgDark,
//                         ),
//                         child: const Icon(Icons.person,
//                             color: AppTheme.accentCyan, size: 24),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Welcome, $userName',
//                               style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w600),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               'Score: ${userScore ?? 0}',
//                               style: TextStyle(
//                                 color: AppTheme.accentCyan.withOpacity(0.8),
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//               const SizedBox(height: 30),
//
//               // Level 1 Button
//               _buildLevelCard(
//                 level: 1,
//                 title: 'LEVEL 1',
//                 subtitle: '40 Image-Based Questions',
//                 icon: Icons.looks_one_rounded,
//                 color: AppTheme.accentCyan,
//                 onTap: () {
//                   if (_currentLevel > 1) {
//                     _showLevel1CompletedDialog();
//                   } else if (_currentLevel == 1) {
//                     _navigateToQuestionScreen(1);
//                   } else {
//                     _showErrorDialog("Level 1 is not yet available.");
//                   }
//                 },
//               ),
//
//               const SizedBox(height: 16),
//
//               // Level 2 Button
//               _buildLevelCard(
//                 level: 2,
//                 title: 'LEVEL 2',
//                 subtitle: '10 Text-Based Puzzles',
//                 icon: Icons.looks_two_rounded,
//                 color: const Color(0xFFBC13FE),
//                 isLocked: _currentLevel < 2,
//                 onTap: () {
//                   if (_currentLevel >= 2) {
//                     _navigateToQuestionScreen(2);
//                   } else if (_currentLevel == 1) {
//                     _showLevelLockedDialog();
//                   } else {
//                     _showErrorDialog("Level 2 is not yet available.");
//                   }
//                 },
//               ),
//
//               const SizedBox(height: 30),
//
//               // Divider
//               Row(
//                 children: [
//                   Expanded(child: Container(height: 1, color: Colors.white10)),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     child: Text(
//                       'PRE-PARADOX',
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.3),
//                         fontSize: 11,
//                         letterSpacing: 2,
//                       ),
//                     ),
//                   ),
//                   Expanded(child: Container(height: 1, color: Colors.white10)),
//                 ],
//               ),
//
//               const SizedBox(height: 20),
//
//               // Mini Games Button
//               AnimatedBuilder(
//                 animation: _pulseAnim,
//                 builder: (context, child) {
//                   return Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                           color: const Color(0xFFBC13FE)
//                               .withOpacity(0.15 * _pulseAnim.value),
//                           blurRadius: 20,
//                           spreadRadius: 2,
//                         ),
//                       ],
//                     ),
//                     child: child,
//                   );
//                 },
//                 child: GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => ParadoxDashboard()),
//                     );
//                   },
//                   child: Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 20, horizontal: 20),
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       borderRadius: BorderRadius.circular(16),
//                       border: Border.all(
//                         color: const Color(0xFFBC13FE).withOpacity(0.3),
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 50,
//                           height: 50,
//                           decoration: BoxDecoration(
//                             color:
//                                 const Color(0xFFBC13FE).withOpacity(0.15),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: const Icon(Icons.games_rounded,
//                               color: Color(0xFFBC13FE), size: 28),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 'MINI GAMES',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   letterSpacing: 2,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 '6 Cyberpunk Challenges',
//                                 style: TextStyle(
//                                   color: Colors.white.withOpacity(0.4),
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Icon(
//                           Icons.arrow_forward_ios_rounded,
//                           color: Colors.white.withOpacity(0.3),
//                           size: 18,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLevelCard({
//     required int level,
//     required String title,
//     required String subtitle,
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//     bool isLocked = false,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
//         decoration: BoxDecoration(
//           color: AppTheme.cardBlue,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: isLocked
//                 ? Colors.white10
//                 : color.withOpacity(0.3),
//           ),
//           boxShadow: isLocked
//               ? []
//               : [
//                   BoxShadow(
//                     color: color.withOpacity(0.08),
//                     blurRadius: 15,
//                     spreadRadius: 1,
//                   ),
//                 ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 50,
//               height: 50,
//               decoration: BoxDecoration(
//                 color: color.withOpacity(isLocked ? 0.05 : 0.12),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(
//                 isLocked ? Icons.lock_rounded : icon,
//                 color: isLocked ? Colors.white24 : color,
//                 size: 28,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(
//                       color: isLocked ? Colors.white38 : Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 2,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       color: isLocked
//                           ? Colors.white.withOpacity(0.2)
//                           : Colors.white.withOpacity(0.4),
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(
//               Icons.play_arrow_rounded,
//               color: isLocked ? Colors.white12 : color,
//               size: 30,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:paradox_2k26/paradox_game/auth_choice_screen.dart';
import 'package:paradox_2k26/paradox_game/level_complete_screen.dart';
import 'package:paradox_2k26/paradox_game/question_screen.dart';
import 'package:paradox_2k26/paradox_game/level2_question_screen.dart';
import 'package:paradox_2k26/paradox_game/sign_in_screen.dart';
import 'package:paradox_2k26/screens/homescreen.dart';
import 'package:paradox_2k26/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String? userName;
  int? userScore;
  int _currentLevel = 1;
  final storage = const FlutterSecureStorage();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _checkAuthAndFetchData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndFetchData() async {
    // ==========================================
    // TESTING MODE: Bypass Auth & API Calls
    // ==========================================
    setState(() {
      userName = "Test User";
      userScore = 999;
      _currentLevel = 1; // Change this to 2 to test Level 2 unlocking
    });
    return; // Exit early to bypass the actual logic below

    /* ORIGINAL AUTHENTICATION LOGIC (Commented out for testing)
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
      return;
    }

    try {
      final homeResponse = await http.get(
        Uri.parse('https://paradox-2k26.onrender.com/'),
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
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignInScreen()),
          );
        }
        return;
      } else {
        _showErrorDialog('Error fetching user data');
        return;
      }

      final levelResponse = await http.get(
        Uri.parse('https://paradox-2k26.onrender.com/api/v1/currentLevel'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (levelResponse.statusCode == 200 || levelResponse.statusCode == 202) {
        final levelData = jsonDecode(levelResponse.body);
        if (levelData['success'] == true) {
          setState(() => _currentLevel = levelData['data']);
        } else {
          _showErrorDialog('Error fetching current level: ${levelData['message']}');
        }
      } else {
        _showErrorDialog('Error fetching current level');
      }
    } catch (e) {
      _showErrorDialog('Network error. Please try again.');
    }
    */
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
            child: const Text('OK', style: TextStyle(color: AppTheme.accentCyan)),
          ),
        ],
      ),
    );
  }

  void _showLevelLockedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBlue,
        title: const Text('Level 2 Locked',
            style: TextStyle(color: Colors.white)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Level 2 is currently locked.',
                style: TextStyle(color: Colors.white70)),
            SizedBox(height: 8),
            Text('Top 50 participants of Level 1 will advance to Level 2.',
                style: TextStyle(color: Colors.white70)),
            SizedBox(height: 8),
            Text('Level 2 starts on April 12th. Stay tuned!',
                style: TextStyle(
                    color: AppTheme.accentCyan, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: AppTheme.accentCyan)),
          ),
        ],
      ),
    );
  }

  void _showLevel1CompletedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBlue,
        title: const Text('Level 1 Completed',
            style: TextStyle(color: Colors.white)),
        content: const Text('You have already completed Level 1.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: AppTheme.accentCyan)),
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
          _checkAuthAndFetchData();
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
        onLevelComplete: () => _checkAuthAndFetchData(),
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
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title Section
              const SizedBox(height: 10),
              Text(
                'PARADOX',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6,
                  fontFamily: 'monospace',
                  shadows: [
                    Shadow(
                      color: AppTheme.accentCyan.withOpacity(0.4),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Let's Begin",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 30),

              // Welcome Card
              if (userName != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBlue,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.accentCyan.withOpacity(0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.accentCyan.withOpacity(0.4),
                          ),
                          color: AppTheme.bgDark,
                        ),
                        child: const Icon(Icons.person,
                            color: AppTheme.accentCyan, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, $userName',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Score: ${userScore ?? 0}',
                              style: TextStyle(
                                color: AppTheme.accentCyan.withOpacity(0.8),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 30),

              // Level 1 Button
              _buildLevelCard(
                level: 1,
                title: 'LEVEL 1',
                subtitle: '40 Image-Based Questions',
                icon: Icons.looks_one_rounded,
                color: AppTheme.accentCyan,
                onTap: () {
                  if (_currentLevel > 1) {
                    _showLevel1CompletedDialog();
                  } else if (_currentLevel == 1) {
                    _navigateToQuestionScreen(1);
                  } else {
                    _showErrorDialog("Level 1 is not yet available.");
                  }
                },
              ),

              const SizedBox(height: 16),

              // Level 2 Button
              _buildLevelCard(
                level: 2,
                title: 'LEVEL 2',
                subtitle: '10 Text-Based Puzzles',
                icon: Icons.looks_two_rounded,
                color: const Color(0xFFBC13FE),
                isLocked: _currentLevel < 2,
                onTap: () {
                  if (_currentLevel >= 2) {
                    _navigateToQuestionScreen(2);
                  } else if (_currentLevel == 1) {
                    _showLevelLockedDialog();
                  } else {
                    _showErrorDialog("Level 2 is not yet available.");
                  }
                },
              ),

              const SizedBox(height: 30),

              // Divider
              Row(
                children: [
                  Expanded(child: Container(height: 1, color: Colors.white10)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'PRE-PARADOX',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 11,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  Expanded(child: Container(height: 1, color: Colors.white10)),
                ],
              ),

              const SizedBox(height: 20),

              // Mini Games Button
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFBC13FE)
                              .withOpacity(0.15 * _pulseAnim.value),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTap: () {
                    // Navigate to Mini Games
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFBC13FE).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color:
                            const Color(0xFFBC13FE).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.games_rounded,
                              color: Color(0xFFBC13FE), size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'MINI GAMES',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '6 Cyberpunk Challenges',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white.withOpacity(0.3),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard({
    required int level,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isLocked = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: AppTheme.cardBlue,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLocked
                ? Colors.white10
                : color.withOpacity(0.3),
          ),
          boxShadow: isLocked
              ? []
              : [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(isLocked ? 0.05 : 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isLocked ? Icons.lock_rounded : icon,
                color: isLocked ? Colors.white24 : color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isLocked ? Colors.white38 : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isLocked
                          ? Colors.white.withOpacity(0.2)
                          : Colors.white.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.play_arrow_rounded,
              color: isLocked ? Colors.white12 : color,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}