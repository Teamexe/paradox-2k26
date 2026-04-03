import 'dart:math';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:paradox/commit-game/bullet_component.dart';
import 'package:paradox/commit-game/cell_component.dart';
import 'package:paradox/commit-game/constants.dart';
import 'package:paradox/commit-game/game_manager.dart';
import 'package:paradox/commit-game/game_state.dart';
import 'package:paradox/commit-game/player_component.dart';

class CommitClashGame extends FlameGame with TapCallbacks {
  late final GameManager gameManager;
  late final List<CellComponent> _cellComponents;
  late final List<PlayerComponent> _playerComponents;

  final String? matchId;
  final String? localUserId;
  final dynamic repository;

  CommitClashGame({this.matchId, this.localUserId, this.repository}) {
    gameManager = GameManager(
      matchId: matchId,
      localUserId: localUserId,
      repository: repository,
    );
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
  }

  @override
  Color backgroundColor() => const Color(0xFF0D1117);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _setupCamera();
    _initializeGame();

    gameManager.gameStatusNotifier.addListener(_onGameStatusChanged);
    gameManager.cellChangedNotifier.addListener(_onCellChanged);
    gameManager.bulletFiredNotifier.addListener(_onBulletFired);
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (final p in _playerComponents) {
      p.updatePosition();
    }
  }

  void _initializeGame() {
    world.removeAll(world.children);

    _cellComponents = [];
    for (int row = 0; row < gridRows; row++) {
      for (int col = 0; col < gridCols; col++) {
        final cell = CellComponent(
          gameManager: gameManager,
          gridPosition: Point(col, row),
        );
        _cellComponents.add(cell);
        world.add(cell);
      }
    }

    _playerComponents = [
      PlayerComponent(player: gameManager.players[0], gameManager: gameManager),
      PlayerComponent(player: gameManager.players[1], gameManager: gameManager),
    ];
    world.addAll(_playerComponents);
  }

  void _setupCamera() {
    final worldSize = Vector2(
      gridCols * (cellSize + cellSpacing),
      gridRows * (cellSize + cellSpacing),
    );
    camera.viewport = FixedResolutionViewport(resolution: worldSize);
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.position = worldSize / 2;
  }

  void _onGameStatusChanged() {
    final status = gameManager.gameStatusNotifier.value;
    if (status == GameStatus.playing) {
      _initializeGame();
    } else if (status == GameStatus.player1Won || status == GameStatus.player2Won) {
      overlays.add('WinOverlay');
    } else if (status == GameStatus.abandoned) {
      overlays.add('DisconnectedOverlay');
    }
  }

  void _onCellChanged() {
    final point = gameManager.cellChangedNotifier.value;
    if (point == null) {
      for (final cell in _cellComponents) {
        cell.updateColor();
      }
      return;
    }

    final index = point.y * gridCols + point.x;
    if (index >= 0 && index < _cellComponents.length) {
      _cellComponents[index].updateColor();
    }
  }

  void _onBulletFired() {
    final data = gameManager.bulletFiredNotifier.value;
    if (data == null || data.length != 2) return;

    final start = data[0];
    final target = data[1];

    final bullet = BulletComponent(
      startGridPosition: start,
      targetGridPosition: target,
      onHit: () {},
    );
    world.add(bullet);
  }
}
