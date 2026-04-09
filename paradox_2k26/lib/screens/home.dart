import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:http/http.dart' as http show get;
import 'package:paradox_2k26/commit_clash_app.dart';
import 'package:paradox_2k26/minigames/flappy_screen.dart';
import 'package:paradox_2k26/minigames/mine_scan_screen.dart';
import 'package:paradox_2k26/minigames/multi_task_screen.dart';
import 'package:paradox_2k26/minigames/node_decryption_screen.dart';
import 'package:paradox_2k26/paradox_game/leaderboard_screen.dart';
import 'package:paradox_2k26/paradox_game/profile_screen.dart';
import 'package:paradox_2k26/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

import '../minigames/lights_out_screen.dart';
import '../paradox_game/auth_choice_screen.dart';
import '../paradox_game/level2_question_screen.dart';
import '../paradox_game/level_complete_screen.dart';
import '../paradox_game/question_screen.dart';
import '../paradox_game/rules_screen.dart';
import '../paradox_game/sign_in_screen.dart';
import 'homescreen.dart';

class ParadoxMainWrapper extends StatefulWidget {
  const ParadoxMainWrapper({super.key});

  @override
  State<ParadoxMainWrapper> createState() => _ParadoxMainWrapperState();
}

class _ParadoxMainWrapperState extends State<ParadoxMainWrapper> {
  int _pageIndex = 1; // Start at index 1 (the center Home tab)
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  // Define your three screens here
  final List<Widget> _screens = [
    ProfileScreen(), // Left Tab
    ParadoxDashboard1(), // Center Tab (Your existing UI)
    LeaderboardScreen(),
    RulesScreen(),// Right Tab
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Crucial for the transparent notch effect
      backgroundColor: const Color(0xFF0A0A12),
      body: _screens[_pageIndex],
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: 1,
        height: 60.0,
        items: <Widget>[
          const Icon(Icons.person_outline, size: 30, color: Colors.white),
          const Icon(Icons.home_filled, size: 30, color: Colors.white),
          const Icon(Icons.leaderboard_outlined, size: 30, color: Colors.white),
          const Icon(Icons.info_outline, size: 30, color: Colors.white),
        ],
        color: const Color(0xFF161F2E), // Match your Level Card color
        buttonBackgroundColor: Colors.deepPurpleAccent, // Neon Purple for the active notch
        backgroundColor: Colors.transparent, // Makes the notch pop
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 400),
        onTap: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
        letIndexChange: (index) => true,
      ),
    );
  }
}

// Model to hold our Game Data
class GameLevel {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color themeColor;
  final String tag;
  final String imagePath;
  final Widget Function() buildScreen;

  GameLevel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.themeColor,
    required this.tag,
    required this.imagePath,
    required this.buildScreen,
  });
}

class ParadoxDashboard1 extends StatefulWidget {
  ParadoxDashboard1({super.key});

  @override
  State<ParadoxDashboard1> createState() => _ParadoxDashboard1State();
}

class _ParadoxDashboard1State extends State<ParadoxDashboard1> {
  String? userName;
  int? userScore;
  int _currentLevel = 1;
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
        Uri.parse('https://paradox-2k26.onrender.com/api/v1/home'),
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
        Uri.parse('https://paradox-2k26.onrender.com/api/v1/currentLevel'),
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
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  // Data for the 6 Games we created
  final List<GameLevel> levels = [
    GameLevel(
      title: "SCREAMING FLAPPY",
      subtitle: "Voice Control",
      icon: Icons.record_voice_over_sharp,
      themeColor: const Color(0xFFFEEA13),
      tag: "Game 1",
      imagePath: 'assets/images/flappy.jpg',
      buildScreen: () => const VoiceFlappyScreen(),
    ),
    GameLevel(
      title: "LIGHTS OUT",
      subtitle: "Toggling Matrix",
      icon: Icons.grid_view_rounded,
      themeColor: const Color(0xFF991FA2),
      tag: "Game 2",
      imagePath: 'assets/images/lightsout.jpg',
      buildScreen: () => const LightsOutScreen(),
    ),
    GameLevel(
      title: "MINE SCAN",
      subtitle: "Deduction Radar",
      icon: Icons.radio,
      themeColor: const Color(0xFF00F2FF),
      tag: "Game 3",
      imagePath: 'assets/images/mine.jpg',
      buildScreen: () => const MineScanScreen(),
    ),
    GameLevel(
      title: "NODE DECRYPT",
      subtitle: "Memory Sequence",
      icon: Icons.memory,
      themeColor: const Color(0xFF39FF14),
      tag: "Game 4",
      imagePath: 'assets/images/node.jpg',
      buildScreen: () => const NodeDecryptionScreen(),
    ),
    GameLevel(
      title: "CORE BREACH",
      subtitle: "Multitasking",
      icon: Icons.warning_amber_rounded,
      themeColor: const Color(0xFFFF003C),
      tag: "Game 5",
      imagePath: 'assets/images/multitask.jpg',
      buildScreen: () => const CoreBreachScreen(),
    ),
    GameLevel(
      title: "COMMIT CLASH",
      subtitle: "Github competition",
      icon: Icons.route_rounded,
      themeColor: const Color(0xFF00F3FF),
      tag: "Game 6",
      imagePath: 'assets/images/github.jpg',
      buildScreen: () => const CommitClashApp(),
    ),
  ];
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
  void _navigateToQuestionScreen(int level) {
    Widget nextScreen;
    if (level == 2) {
      nextScreen = Level2QuestionScreen(
        level: level,
        onLevelComplete: () {

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
      backgroundColor: const Color(0xFF0A0A12),
      body: CustomScrollView(
        slivers: [
          // 1. TOP BANNER SECTION
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Banner Background
                Container(
                  height: 200,
                  width: double.infinity,
                  margin: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 50,
                    bottom: 20,
                  ),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: const AssetImage("assets/images/para.jpg"),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.red.withOpacity(0.4),
                        BlendMode.dstATop,
                      ),
                    ),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Mini Games",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -2,
                        ),
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>ParadoxDashboard()));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFBC13FE),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "ExploreMore",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_circle_right_rounded),
                            iconSize: 30,
                            color: Colors.blue,
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>ParadoxDashboard()));
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 2. STICKER IMAGE (Top Right)
                Positioned(
                  top: 50,
                  right: 0,
                  child: Image.asset(
                    'assets/images/sticker.png',
                    height: 180,
                    width: 180,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(
                        Icons.image,
                        color: Colors.white24,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. GRID OF GAMES (Wrapped in SliverToBoxAdapter)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Main Title with Stacked Neon Glow
                      const Text(
                        'PARADOX',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48, // Increased size for better visual hierarchy
                          fontWeight: FontWeight.w900, // Maximum boldness
                          letterSpacing: 12, // Wider spacing feels more cinematic
                          fontFamily: 'monospace',
                          shadows: [
                            // Stacking shadows creates a realistic, intense neon glow
                            Shadow(color: Colors.purpleAccent, blurRadius: 10),
                            Shadow(color: Colors.cyan, blurRadius: 20),
                            Shadow(color: Colors.blue, blurRadius: 30),
                            Shadow(color: Colors.purple, blurRadius: 40),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16), // Slightly more breathing room

                      // Subtitle framed as a futuristic, clickable-looking prompt
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.cyan.withOpacity(0.05), // Subtle background tint
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.deepPurple.withOpacity(0.3),
                            width: 1,
                          ),
                          // Optional subtle glow behind the subtitle box
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurpleAccent.withOpacity(0.1),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Text(
                          "LET'S BEGIN", // All caps usually fits this aesthetic better
                          style: TextStyle(
                            color: Colors.purple.withOpacity(0.9), // Tying it to the main glow
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 4, // Increased spacing to match the title's vibe
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Welcome Card
                  if (userName != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.accentCyan,
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
                    color: Colors.deepPurpleAccent,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildGamePoster(BuildContext context, GameLevel game) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => game.buildScreen()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF16213E).withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),

          // Use a background pattern or subtle image
          image: DecorationImage(
            image: AssetImage(game.imagePath),
            fit: BoxFit.cover,

            colorFilter: ColorFilter.mode(
              game.themeColor.withOpacity(0.3),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Poster Glow
              Positioned(
                top: -20,
                right: -20,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: game.themeColor.withOpacity(0.2),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.tag,
                      style: TextStyle(
                        color: game.themeColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const Spacer(),
                    Icon(game.icon, color: game.themeColor, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      game.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      game.subtitle,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12), // Reduced margin between cards
      decoration: BoxDecoration(
        color: const Color(0xFF161F2E), // Using your dark background color
        borderRadius: BorderRadius.circular(16), // Slightly smaller radius
        border: Border.all(
          color: isLocked ? Colors.white.withOpacity(0.05) : color.withOpacity(0.5),
          width: isLocked ? 1 : 1.5,
        ),
        boxShadow: isLocked
            ? []
            : [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLocked ? null : onTap,
            splashColor: color.withOpacity(0.2),
            highlightColor: color.withOpacity(0.1),
            child: Stack(
              children: [
                // Gamified Watermark Background
                Positioned(
                  right: -15,
                  bottom: -25,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Icon(
                      isLocked ? Icons.lock_outline : icon,
                      size: 90, // Reduced watermark size
                      color: isLocked
                          ? Colors.white.withOpacity(0.02)
                          : color.withOpacity(0.05),
                    ),
                  ),
                ),

                // Main Content
                Padding(
                  // REDUCED PADDING: This is the main factor making it slimmer
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  child: Row(
                    children: [
                      // Icon Box
                      Container(
                        width: 46, // Reduced from 56
                        height: 46, // Reduced from 56
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isLocked
                                ? [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)]
                                : [color.withOpacity(0.2), color.withOpacity(0.05)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isLocked
                                ? Colors.transparent
                                : color.withOpacity(0.3),
                          ),
                        ),
                        child: Icon(
                          isLocked ? Icons.lock_rounded : icon,
                          color: isLocked ? Colors.white38 : color,
                          size: 24, // Slightly smaller icon
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Texts
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // NOTE: I removed the extra "Level Badge" here

                            // Title
                            Text(
                              title, // Will now only show once!
                              style: TextStyle(
                                color: isLocked ? Colors.white38 : Colors.white,
                                fontSize: 16, // Reduced from 18
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 2), // Tighter spacing

                            // Subtitle
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: isLocked
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.white.withOpacity(0.5),
                                fontSize: 12, // Reduced from 13
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Play / Action Button
                      Container(
                        width: 38, // Reduced from 44
                        height: 38, // Reduced from 44
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isLocked
                              ? Colors.white.withOpacity(0.05)
                              : color,
                          boxShadow: isLocked
                              ? []
                              : [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Icon(
                          isLocked ? Icons.lock_clock : Icons.play_arrow_rounded,
                          color: isLocked ? Colors.white24 : Colors.white,
                          size: 22, // Reduced from 26
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }}
