import 'package:flutter/material.dart';
import 'package:paradox_2k26/commit_clash_app.dart';
import 'package:paradox_2k26/minigames/flappy_screen.dart';
import 'package:paradox_2k26/minigames/mine_scan_screen.dart';
import 'package:paradox_2k26/minigames/multi_task_screen.dart';
import 'package:paradox_2k26/minigames/node_decryption_screen.dart';
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
      appBar: AppBar(

        title: const Text('Mini Games'),
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.keyboard_arrow_left)),
        centerTitle: true, // Optional: Centers the text
        automaticallyImplyLeading: false, // Removes the back button if it exists
        elevation: 0, // Optional: Removes the shadow for a flat look
      ),
      backgroundColor: const Color(0xFF0A0A12),
      body: CustomScrollView(
        slivers: [
          // 1. TOP BANNER SECTION


          // 3. GRID OF GAMES
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
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
