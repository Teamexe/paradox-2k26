import 'dart:math';
import 'package:flutter/material.dart';
import 'package:paradox/commit-game/constants.dart';
import 'package:paradox/screens/matchmaking_screen.dart';
import 'package:paradox/services/firebase_service.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isLoading = false;
  late List<List<int>> _miniGrid;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    final rng = Random();
    _miniGrid = List.generate(7, (_) => List.generate(20, (_) {
      final roll = rng.nextDouble();
      if (roll < 0.4) return 0;
      if (roll < 0.6) return 1;
      if (roll < 0.8) return 2;
      if (roll < 0.92) return 3;
      return 4;
    }));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _commitColor(int level) {
    switch (level) {
      case 0: return const Color(0xFF161B22);
      case 1: return commitLevel1;
      case 2: return commitLevel2;
      case 3: return commitLevel3;
      default: return commitLevel4;
    }
  }

  Future<void> _onPlayOnline() async {
    setState(() => _isLoading = true);
    try {
      final user = await FirebaseService().signInAnonymously();
      if (user != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MatchmakingScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Sign in failed: $e"),
            backgroundColor: const Color(0xFF3D1A1A),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              _buildMiniGrid(),
              const SizedBox(height: 32),
              const Text(
                'COMMIT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 8,
                  height: 1.0,
                ),
              ),
              const Text(
                'CLASH',
                style: TextStyle(
                  color: Color(0xFF39D353),
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 8,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Paradox 2k26',
                style: TextStyle(
                  color: const Color(0xFF8B949E),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: commitLevel4.withOpacity(0.15 * _pulseAnimation.value),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: child,
                  );
                },
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF238636),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : _onPlayOnline,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_arrow_rounded, size: 24),
                              SizedBox(width: 8),
                              Text(
                                'Play Online',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Row(
                children: [
                  Expanded(child: Container(height: 1, color: const Color(0xFF21262D))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'HOW TO PLAY',
                      style: TextStyle(
                        color: const Color(0xFF8B949E),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  Expanded(child: Container(height: 1, color: const Color(0xFF21262D))),
                ],
              ),
              const SizedBox(height: 24),
              _buildRuleCard(
                icon: Icons.grid_on_rounded,
                iconColor: commitLevel3,
                title: 'The Grid',
                description: 'Navigate a GitHub-style contribution graph. '
                    'Each green cell is a "commit" that blocks your path.',
              ),
              const SizedBox(height: 12),
              _buildRuleCard(
                icon: Icons.touch_app_rounded,
                iconColor: commitLevel4,
                title: 'Tap to Act',
                description: 'Tap an adjacent empty cell to move there. '
                    'Tap a green commit cell to destroy it (reduce its level by 1).',
              ),
              const SizedBox(height: 12),
              _buildRuleCard(
                icon: Icons.looks_one_rounded,
                iconColor: commitLevel1,
                title: 'Commit Levels',
                description: 'Commits have 1–4 strength levels. '
                    'A level-4 commit needs 4 taps to clear. Level-1 needs just 1 tap.',
              ),
              const SizedBox(height: 12),
              _buildRuleCard(
                icon: Icons.swap_vert_rounded,
                iconColor: player1Color,
                title: 'Turn-Based',
                description: 'Players alternate turns. Each turn you can either '
                    'move to an empty cell or shoot one commit. Choose wisely!',
              ),
              const SizedBox(height: 12),
              _buildRuleCard(
                icon: Icons.emoji_events_rounded,
                iconColor: const Color(0xFFE3B341),
                title: 'Win Condition',
                description: 'Race to the opposite end of the grid! '
                    'The first player to reach the top row wins the match.',
              ),
              const SizedBox(height: 12),
              _buildRuleCard(
                icon: Icons.visibility_rounded,
                iconColor: const Color(0xFF8B949E),
                title: 'Fog of War',
                description: 'You can only see cells within a $visionRadius-cell radius. '
                    'Plan your path carefully — the unknown awaits beyond the fog.',
              ),
              const SizedBox(height: 40),
              Text(
                'made with 🤍 for Paradox 2k26',
                style: TextStyle(
                  color: const Color(0xFF484F58),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniGrid() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22).withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF21262D), width: 1),
      ),
      child: Column(
        children: List.generate(7, (row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(20, (col) {
                return Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.all(1.2),
                  decoration: BoxDecoration(
                    color: _commitColor(_miniGrid[row][col]),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRuleCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF21262D), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: const Color(0xFF8B949E),
                    fontSize: 13,
                    height: 1.4,
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
