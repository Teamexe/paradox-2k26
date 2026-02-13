import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:paradox/commit-game/constants.dart';

class BulletComponent extends PositionComponent {
  final Point<int> startGridPosition;
  final Point<int> targetGridPosition;
  final VoidCallback onHit;

  late final Vector2 _targetPosition;
  final double _speed = 600.0;
  double _trailOpacity = 1.0;

  BulletComponent({
    required this.startGridPosition,
    required this.targetGridPosition,
    required this.onHit,
  }) {
    size = Vector2.all(6);
    anchor = Anchor.center;
    final startPos = Vector2(
      startGridPosition.x * (cellSize + cellSpacing) + cellSize / 2,
      startGridPosition.y * (cellSize + cellSpacing) + cellSize / 2,
    );

    _targetPosition = Vector2(
      targetGridPosition.x * (cellSize + cellSpacing) + cellSize / 2,
      targetGridPosition.y * (cellSize + cellSpacing) + cellSize / 2,
    );

    position = startPos;
    angle = (_targetPosition - startPos).screenAngle();
  }

  @override
  void update(double dt) {
    super.update(dt);

    final direction = (_targetPosition - position).normalized();
    position += direction * _speed * dt;

    if (position.distanceTo(_targetPosition) < 5.0) {
      onHit();
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final center = (size / 2).toOffset();
    final radius = size.x / 2;

    final glowPaint = Paint()
      ..color = commitLevel4.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawCircle(center, radius * 2, glowPaint);

    final corePaint = Paint()..color = commitLevel4;
    canvas.drawCircle(center, radius, corePaint);

    final hotPaint = Paint()..color = Colors.white.withOpacity(0.8);
    canvas.drawCircle(center, radius * 0.4, hotPaint);
  }
}
