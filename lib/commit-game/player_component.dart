import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:paradox/commit-game/game_manager.dart';
import 'package:paradox/commit-game/constants.dart';
import 'package:paradox/commit-game/player_model.dart';

class PlayerComponent extends PositionComponent {
  final Player player;
  final GameManager gameManager;

  late final Paint _fillPaint;
  late final Paint _ringPaint;
  bool _isActive = false;

  PlayerComponent({required this.player, required this.gameManager}) {
    final color = player.id == 0 ? player1Color : player2Color;
    _fillPaint = Paint()..color = color;
    _ringPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    size = Vector2.all(cellSize * 0.65);
    anchor = Anchor.center;
    priority = 10;
    updatePosition();
  }

  @override
  void onMount() {
    super.onMount();
    gameManager.currentPlayerNotifier.addListener(_updateActiveStatus);
    _updateActiveStatus();
  }

  @override
  void onRemove() {
    gameManager.currentPlayerNotifier.removeListener(_updateActiveStatus);
    super.onRemove();
  }

  @override
  void render(Canvas canvas) {
    final center = (size / 2).toOffset();
    final radius = size.x / 2;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    canvas.drawCircle(center + const Offset(1, 1), radius * 0.7, shadowPaint);

    canvas.drawCircle(center, radius * 0.7, _fillPaint);

    if (_isActive) {
      canvas.drawCircle(center, radius * 0.85, _ringPaint);
    }

    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.25);
    canvas.drawCircle(
      center + Offset(-radius * 0.15, -radius * 0.15),
      radius * 0.2,
      highlightPaint,
    );
  }

  void _updateActiveStatus() {
    _isActive = gameManager.currentPlayer.id == player.id;
  }

  void updatePosition() {
    position = Vector2(
      player.position.x * (cellSize + cellSpacing) + cellSize / 2,
      player.position.y * (cellSize + cellSpacing) + cellSize / 2,
    );
  }
}
