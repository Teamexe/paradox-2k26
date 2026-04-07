import 'package:flutter/material.dart';
import 'package:paradox/minigames/lights_out_screen.dart';
import 'package:paradox/minigames/mine_scan_screen.dart';
import 'package:paradox/minigames/multi_task_screen.dart';
import 'package:paradox/minigames/node_decryption_screen.dart';
import 'package:paradox/minigames/pathfinder_screen.dart';
import 'package:paradox/commit_clash_app.dart';

class _GameInfo {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Widget Function() buildScreen;

  const _GameInfo({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.buildScreen,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late final List<_GameInfo> games = [
    _GameInfo(
      title: 'Lights Out',
      subtitle: 'Turn all lights OFF',
      icon: Icons.lightbulb_outline,
      accentColor: const Color(0xFFBC13FE),
      buildScreen: () => const LightsOutScreen(),
    ),
    _GameInfo(
      title: 'Mine Scan',
      subtitle: 'Data Breach Protocol',
      icon: Icons.radar_rounded,
      accentColor: const Color(0xFF00F2FF),
      buildScreen: () => const MineScanScreen(),
    ),
    _GameInfo(
      title: 'Core Breach',
      subtitle: 'Multitask Under Pressure',
      icon: Icons.whatshot_rounded,
      accentColor: Colors.redAccent,
      buildScreen: () => const CoreBreachScreen(),
    ),
    _GameInfo(
      title: 'Node Decrypt',
      subtitle: 'Memory Sequence',
      icon: Icons.memory_rounded,
      accentColor: const Color(0xFF39FF14),
      buildScreen: () => const NodeDecryptionScreen(),
    ),
    _GameInfo(
      title: 'Pathfinder',
      subtitle: 'Trace the Signal',
      icon: Icons.route_rounded,
      accentColor: const Color(0xFF00F3FF),
      buildScreen: () => const PathfinderScreen(),
    ),
    _GameInfo(
      title: 'Commit Clash',
      subtitle: 'Online Grid Battle',
      icon: Icons.grid_on_rounded,
      accentColor: const Color(0xFF39D353),
      buildScreen: () => const CommitClashApp(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // HEADER SECTION
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Paradox",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Event Games",
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      ),
                    ],
                  ),
                  Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Icon(Icons.notifications_none, color: Colors.white),
                  ),
                ],
              ),
            ),

            // GAME GRID
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.85,
                ),
                itemCount: games.length,
                itemBuilder: (context, index) {
                  final game = games[index];
                  return _buildGameCard(context, game);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, _GameInfo game) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => game.buildScreen()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF152238),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: game.accentColor.withOpacity(0.25), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: game.accentColor.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Subtle gradient glow at top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 80,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      game.accentColor.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon container
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: game.accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: game.accentColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(game.icon, color: game.accentColor, size: 26),
                  ),
                  const Spacer(),
                  // Title
                  Text(
                    game.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Subtitle
                  Text(
                    game.subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Play button
                  Container(
                    width: double.infinity,
                    height: 34,
                    decoration: BoxDecoration(
                      color: game.accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: game.accentColor.withOpacity(0.3),
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow_rounded, color: game.accentColor, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            'PLAY',
                            style: TextStyle(
                              color: game.accentColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}