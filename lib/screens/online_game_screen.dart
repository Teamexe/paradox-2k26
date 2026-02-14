import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:paradox/commit-game/commit_clash_game.dart';
import 'package:paradox/commit-game/game_overlay.dart';
import 'package:paradox/commit-game/game_state.dart';
import 'package:paradox/repositories/firestore_game_repository.dart';
import 'package:paradox/services/firebase_service.dart';

class OnlineGameScreen extends StatefulWidget {
  final String matchId;

  const OnlineGameScreen({super.key, required this.matchId});

  @override
  State<OnlineGameScreen> createState() => _OnlineGameScreenState();
}

class _OnlineGameScreenState extends State<OnlineGameScreen> {
  late CommitClashGame game;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseService().currentUserId!;
    game = CommitClashGame(
      matchId: widget.matchId,
      localUserId: userId,
      repository: FirestoreGameRepository(),
    );
  }

  @override
  void dispose() {
    if (game.gameManager.gameStatusNotifier.value == GameStatus.playing) {
      final userId = FirebaseService().currentUserId;
      if (userId != null) {
        FirestoreGameRepository().updateMatchStatus(widget.matchId, 'abandoned');
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: game,
        overlayBuilderMap: {
          'GameOverlay': (context, game) =>
              GameOverlay(game: game as CommitClashGame),
          'WaitingOverlay': (context, game) => const Center(
            child: Card(
              color: Colors.black54,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text("Waiting for opponent...", style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
          'WinOverlay': (context, game) => _buildWinOverlay(context, game as CommitClashGame),
          'DisconnectedOverlay': (context, game) => _buildDisconnectedOverlay(context),
        },
        initialActiveOverlays: const ['GameOverlay'],
      ),
    );
  }

  Widget _buildDisconnectedOverlay(BuildContext context) {
    return Center(
      child: Card(
        color: Colors.red.withOpacity(0.8),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Opponent Disconnected", style: TextStyle(color: Colors.white, fontSize: 24)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Back to Menu"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWinOverlay(BuildContext context, CommitClashGame game) {
    final status = game.gameManager.gameStatusNotifier.value;
    final myIndex = game.gameManager.myPlayerIndex;

    bool didIWin = false;
    if (status == GameStatus.player1Won && myIndex == 0) {
      didIWin = true;
    } else if (status == GameStatus.player2Won && myIndex == 1) {
      didIWin = true;
    }

    final title = didIWin ? '🏆 You Win!' : '💀 You Lose!';
    final subtitle = didIWin
        ? 'You reached the finish line first!'
        : 'Your opponent reached the finish line first.';
    final color = didIWin ? const Color(0xFF39D353) : const Color(0xFFf78166);
    final bgColor = didIWin
        ? const Color(0xFF0E4429).withOpacity(0.95)
        : const Color(0xFF3D1A1A).withOpacity(0.95);

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.6), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Back to Menu',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
