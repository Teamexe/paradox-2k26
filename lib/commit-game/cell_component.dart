import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:paradox/commit-game/game_manager.dart';
import 'package:paradox/commit-game/constants.dart';

class CellComponent extends PositionComponent with TapCallbacks {
  final GameManager gameManager;
  final Point<int> gridPosition;
  late final Paint _fillPaint;
  late final Paint _borderPaint;
  double _targetOpacity = 1.0;
  double _currentOpacity = 1.0;

  CellComponent({
    required this.gameManager,
    required this.gridPosition,
  }) {
    size = Vector2.all(cellSize);
    position = Vector2(
      gridPosition.x * (cellSize + cellSpacing),
      gridPosition.y * (cellSize + cellSpacing),
    );
    _fillPaint = Paint();
    _borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    updateColor();
  }

  @override
  void onTapUp(TapUpEvent event) {
    gameManager.handleTap(gridPosition);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if ((_currentOpacity - _targetOpacity).abs() > 0.01) {
      _currentOpacity += (_targetOpacity - _currentOpacity) *
          (dt * 6.0).clamp(0.0, 1.0);
    } else {
      _currentOpacity = _targetOpacity;
    }
  }

  @override
  void render(Canvas canvas) {
    final rect = size.toRect().deflate(0.5);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(2));

    final isVisible = gameManager.isCellVisible(gridPosition);
    _targetOpacity = isVisible ? 1.0 : 0.15;

    if (_currentOpacity < 0.2) {
      final fogFill = Paint()..color = const Color(0xFF161B22).withOpacity(_currentOpacity);
      canvas.drawRRect(rrect, fogFill);
      return;
    }

    final commits = gameManager.grid[gridPosition.y][gridPosition.x];
    final cellColor = gameManager.getCellColor(commits);

    if (commits == 0) {
      final emptyFill = Paint()..color = openCellColor;
      canvas.drawRRect(rrect, emptyFill);
    } else {
      _fillPaint.color = cellColor.withOpacity(_currentOpacity);
      canvas.drawRRect(rrect, _fillPaint);
    }
  }

  void updateColor() {}
}
