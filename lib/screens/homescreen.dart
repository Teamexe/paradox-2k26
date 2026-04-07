import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:paradox_2k26/commit_clash_app.dart';
import 'package:paradox_2k26/minigames/flappy_screen.dart';
import 'package:paradox_2k26/minigames/mine_scan_screen.dart';
import 'package:paradox_2k26/minigames/multi_task_screen.dart';
import 'package:paradox_2k26/minigames/node_decryption_screen.dart';
=======
import 'package:paradox/commit_clash_app.dart';
import 'package:paradox/minigames/flappy_screen.dart';
import 'package:paradox/minigames/mine_scan_screen.dart';
import 'package:paradox/minigames/multi_task_screen.dart';
import 'package:paradox/minigames/node_decryption_screen.dart';
>>>>>>> main
import 'package:url_launcher/url_launcher.dart';

import '../minigames/lights_out_screen.dart';

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

class ParadoxDashboard extends StatelessWidget {
  ParadoxDashboard({super.key});

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
                      image: AssetImage("assets/images/para.jpg"),
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
                        "ParaDoTexe",
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
                            onTap: () async {
                              final Uri url = Uri.parse(
                                "https://drive.google.com/drive/folders/13e5_gMNcVEiUkmeNUuu5qxfuj2JkrZ9M?usp=sharing",
                              );

                              // Check if the URL can be launched first
                              if (await canLaunchUrl(url)) {
                                await launchUrl(
                                  url,
                                  mode: LaunchMode
                                      .externalApplication, // Opens in Chrome/Safari/Drive App
                                );
                              } else {
                                // If it fails, try a fallback mode
                                await launchUrl(
                                  url,
                                  mode: LaunchMode.platformDefault,
                                );
                              }
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
                                "COMING SOON",
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
                            onPressed: () async {
                              final Uri url = Uri.parse(
                                "https://drive.google.com/drive/folders/13e5_gMNcVEiUkmeNUuu5qxfuj2JkrZ9M?usp=sharing",
                              );

                              // Check if the URL can be launched first
                              if (await canLaunchUrl(url)) {
                                await launchUrl(
                                  url,
                                  mode: LaunchMode
                                      .externalApplication, // Opens in Chrome/Safari/Drive App
                                );
                              } else {
                                // If it fails, try a fallback mode
                                await launchUrl(
                                  url,
                                  mode: LaunchMode.platformDefault,
                                );
                              }
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
                    'assets/images/sticker.png', // ADD YOUR IMAGE HERE
                    height: 180,
                    width: 180,
                    fit: BoxFit.contain,
                    // Error builder so the app doesn't crash if image is missing
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

          // 3. GRID OF GAMES
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 0.85, // Adjust for poster height
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final game = levels[index];
                return _buildGamePoster(context, game);
              }, childCount: levels.length),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
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
}
