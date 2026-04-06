import 'package:flutter/material.dart';
import 'package:paradox_2k26/commit-game/commit_clash_game.dart';
import 'package:paradox_2k26/commit-game/game_state.dart';
import 'package:paradox_2k26/commit-game/constants.dart';

class GameOverlay extends StatelessWidget {
  final CommitClashGame game;

  const GameOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<GameStatus>(
      valueListenable: game.gameManager.gameStatusNotifier,
      builder: (context, status, child) {
        final isPlaying = status == GameStatus.playing;
        return IgnorePointer(
          ignoring: isPlaying,
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: ValueListenableBuilder<int>(
                      valueListenable: game.gameManager.currentPlayerNotifier,
                      builder: (context, currentPlayerId, child) {
                        final isMyTurn = game.gameManager.isMyTurn;
                        final turnText = isMyTurn ? "Your Turn" : "Opponent's Turn";

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161B22),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isMyTurn
                                  ? commitLevel3.withOpacity(0.6)
                                  : const Color(0xFF30363D),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isMyTurn ? commitLevel4 : const Color(0xFF484F58),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                turnText,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isMyTurn
                                      ? Colors.white
                                      : const Color(0xFF8B949E),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (!isPlaying)
                  Container(
                    color: Colors.black.withOpacity(0.7),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getWinMessage(status, game.gameManager.amIPlayer1),
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: _getWinColor(status, game.gameManager.amIPlayer1),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF238636),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10,
                              ),
                            ),
                            onPressed: () {
                              game.gameManager.restartGame();
                            },
                            child: const Text("Play Again"),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getWinMessage(GameStatus status, bool amIPlayer1) {
    if (status == GameStatus.player1Won) {
      return amIPlayer1 ? "You Win!" : "You Lose!";
    } else if (status == GameStatus.player2Won) {
      return amIPlayer1 ? "You Lose!" : "You Win!";
    }
    return "";
  }

  Color _getWinColor(GameStatus status, bool amIPlayer1) {
    if (status == GameStatus.player1Won) {
      return amIPlayer1 ? commitLevel4 : const Color(0xFFf78166);
    } else if (status == GameStatus.player2Won) {
      return amIPlayer1 ? const Color(0xFFf78166) : commitLevel4;
    }
    return Colors.white;
  }
}
