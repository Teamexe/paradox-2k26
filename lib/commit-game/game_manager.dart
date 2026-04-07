import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:paradox_2k26/commit-game/constants.dart';
import 'package:paradox_2k26/commit-game/game_state.dart';
import 'package:paradox_2k26/commit-game/map_generator.dart';
import 'package:paradox_2k26/commit-game/player_model.dart';
import 'package:paradox_2k26/models/match_model.dart';

class GameManager {
  late List<List<int>> _grid;
  late List<Player> _players;
  int _currentPlayerIndex = 0;
  final ValueNotifier<GameStatus> gameStatusNotifier = ValueNotifier(
    GameStatus.playing,
  );
  final ValueNotifier<int> currentPlayerNotifier = ValueNotifier(0);
  final GameNotifier<Point<int>?> cellChangedNotifier = GameNotifier(null);
  final GameNotifier<List<Point<int>>?> bulletFiredNotifier = GameNotifier(null);

  List<List<int>> get grid => _grid;
  List<Player> get players => _players;
  Player get currentPlayer => _players[_currentPlayerIndex];

  GameManager({this.matchId, this.localUserId, this.repository}) {
    initializeGame();

    if (isOnline) {
      _initializeOnline();
    }
  }

  final String? matchId;
  final String? localUserId;
  final dynamic repository;

  bool get isOnline => matchId != null && localUserId != null && repository != null;

  StreamSubscription? _matchSubscription;
  int? _myPlayerIndex;
  dynamic _lastHandledMove;

  bool get isMyTurn => isOnline ? _myPlayerIndex == _currentPlayerIndex : true;
  bool get amIPlayer1 => isOnline ? _myPlayerIndex == 0 : true;
  int? get myPlayerIndex => _myPlayerIndex;

  void _initializeOnline() {
    _matchSubscription = repository.listenToMatch(matchId!).listen((matchModel) {
      if (matchModel != null) {
        _updateFromMatch(matchModel);
      }
    }, onError: (e) {
      debugPrint("Stream Error: $e");
    });
  }

  void _updateFromMatch(MatchModel match) {
    _grid = match.getGrid2D(gridRows, gridCols, playerIndex: 0);

    if (_players.isEmpty) {
      _players = [
        Player(id: 0, position: match.playerPositions[0]),
        Player(id: 1, position: match.playerPositions[1]),
      ];
    } else {
      _players[0].position = match.playerPositions[0];
      _players[1].position = match.playerPositions[1];
    }

    if (localUserId != null) {
      _myPlayerIndex = match.players.indexOf(localUserId!);
    }

    _currentPlayerIndex = match.activePlayerIndex;
    currentPlayerNotifier.value = _currentPlayerIndex;

    if (match.gameStatus == 'playing') {
      gameStatusNotifier.value = GameStatus.playing;
    } else if (match.gameStatus == 'finished') {
      if (match.winnerId != null) {
        final winnerIndex = match.players.indexOf(match.winnerId!);
        gameStatusNotifier.value = winnerIndex == 0 ? GameStatus.player1Won : GameStatus.player2Won;
      }
    } else if (match.gameStatus == 'abandoned') {
      gameStatusNotifier.value = GameStatus.abandoned;
    }

    if (match.lastMove != null) {
      final moveTimestamp = match.lastMove!['timestamp'];
      if (_lastHandledMove != moveTimestamp) {
        _lastHandledMove = moveTimestamp;
        final type = match.lastMove!['type'];
        final moveMaker = match.lastMove!['playerId'];
        final isMyMove = (moveMaker == localUserId);
        if (type == 'shoot' && !isMyMove) {
          final fromMap = match.lastMove!['from'];
          final toMap = match.lastMove!['to'];
          final from = Point(fromMap['x'] as int, fromMap['y'] as int);
          final to = Point(toMap['x'] as int, toMap['y'] as int);

          bulletFiredNotifier.value = [from, to];
          bulletFiredNotifier.notify();
        }
      }
    }

    cellChangedNotifier.value = null;
    cellChangedNotifier.notify();
  }

  void initializeGame({int? seed}) {
    if (isOnline) {
      _grid = List.generate(gridRows, (_) => List.filled(gridCols, 0));
      _players = [
        Player(id: 0, position: const Point(2, 6)),
        Player(id: 1, position: const Point(17, 6)),
      ];
    } else {
      final mapGen = MapGenerator(seed: seed);
      _grid = mapGen.generateMazeGrid(gridRows, gridCols);

      _players = [
        Player(id: 0, position: const Point(2, 6)),
        Player(id: 1, position: const Point(17, 6)),
      ];

      for (var player in _players) {
        if (isValidGridPosition(player.position)) {
          _grid[player.position.y][player.position.x] = 0;
        }
      }
    }

    _currentPlayerIndex = 0;
    gameStatusNotifier.value = GameStatus.playing;
    currentPlayerNotifier.value = _currentPlayerIndex;
    cellChangedNotifier.notify();
  }

  bool isCellVisible(Point<int> cell) {
    if (gameStatusNotifier.value != GameStatus.playing) return true;

    for (final player in _players) {
      final dx = (cell.x - player.position.x).abs();
      final dy = (cell.y - player.position.y).abs();
      if (sqrt(dx * dx + dy * dy) <= visionRadius) {
        return true;
      }
    }
    return false;
  }

  bool isValidGridPosition(Point<int> point) {
    return point.x >= 0 &&
        point.x < gridCols &&
        point.y >= 0 &&
        point.y < gridRows;
  }

  void handleTap(Point<int> tappedPoint) {
    if (gameStatusNotifier.value != GameStatus.playing) return;

    if (isOnline) {
      if (_myPlayerIndex == null) return;
      if (_myPlayerIndex != _currentPlayerIndex) return;
    }

    final player = currentPlayer;
    final playerPos = player.position;

    if (!isValidGridPosition(tappedPoint)) return;

    final dx = (tappedPoint.x - playerPos.x).abs();
    final dy = (tappedPoint.y - playerPos.y).abs();
    final isAdjacent = (dx + dy) == 1;
    if (!isAdjacent) return;

    final targetCellCommits = _grid[tappedPoint.y][tappedPoint.x];

    if (isOnline) {
      String type = targetCellCommits == 0 && !_isCellOccupied(tappedPoint) ? 'move' : 'shoot';
      if (targetCellCommits > 0) type = 'shoot';

      if (targetCellCommits == 0 && _isCellOccupied(tappedPoint)) return;

      if (type == 'shoot') {
        _grid[tappedPoint.y][tappedPoint.x]--;
        cellChangedNotifier.value = tappedPoint;
        cellChangedNotifier.notify();
        bulletFiredNotifier.value = [playerPos, tappedPoint];
        bulletFiredNotifier.notify();
      } else if (type == 'move') {
        player.position = tappedPoint;
      }

      _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;
      currentPlayerNotifier.value = _currentPlayerIndex;
      cellChangedNotifier.value = null;
      cellChangedNotifier.notify();

      repository.performAction(matchId!, localUserId!, {
        'from': {'x': playerPos.x, 'y': playerPos.y},
        'to': {'x': tappedPoint.x, 'y': tappedPoint.y},
        'type': type,
        'playerId': localUserId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      return;
    }

    bool actionTaken = false;

    if (targetCellCommits == 0) {
      if (!_isCellOccupied(tappedPoint)) {
        _performMove(player, tappedPoint);
        actionTaken = true;
      }
    } else {
      _performShoot(tappedPoint);
      actionTaken = true;
    }
    if (actionTaken) {
      _switchTurn();
    }
  }

  bool _isCellOccupied(Point<int> point) {
    for (final player in _players) {
      if (player.position == point) return true;
    }
    return false;
  }

  void _performMove(Player player, Point<int> destination) {
    if (_isCellOccupied(destination)) return;

    player.position = destination;

    if (destination.y == gridRows - 1) {
      gameStatusNotifier.value = player.id == 0
          ? GameStatus.player1Won
          : GameStatus.player2Won;
    }
  }

  void _performShoot(Point<int> target) {
    if (_grid[target.y][target.x] > 0) {
      bulletFiredNotifier.value = [currentPlayer.position, target];
      bulletFiredNotifier.notify();

      _grid[target.y][target.x]--;
      cellChangedNotifier.value = target;
      cellChangedNotifier.notify();
    }
  }

  void _switchTurn() {
    if (gameStatusNotifier.value == GameStatus.playing) {
      _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;
      currentPlayerNotifier.value = _currentPlayerIndex;
    }
  }

  void restartGame({int? seed}) {
    if (isOnline) return;
    initializeGame(seed: seed);
  }

  Color getCellColor(int commitCount) {
    if (commitCount == 0) return openCellColor;

    switch (commitCount) {
      case 1: return commitLevel1;
      case 2: return commitLevel2;
      case 3: return commitLevel3;
      default: return commitLevel4;
    }
  }
}

class GameNotifier<T> extends ValueNotifier<T> {
  GameNotifier(super.value);

  void notify() {
    notifyListeners();
  }
}
