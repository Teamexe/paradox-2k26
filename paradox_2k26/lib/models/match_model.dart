import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class MatchModel {
  final String id;
  final List<String> players;
  final List<int> grid;
  final List<int> grid2;
  final int activePlayerIndex;
  final String gameStatus;
  final String? winnerId;
  final Map<String, dynamic>? lastMove;
  final DateTime createdAt;
  final List<Point<int>> playerPositions;

  MatchModel({
    required this.id,
    required this.players,
    required this.grid,
    List<int>? grid2,
    required this.activePlayerIndex,
    required this.gameStatus,
    this.winnerId,
    this.lastMove,
    required this.createdAt,
    required this.playerPositions,
  }) : grid2 = grid2 ?? grid;

  factory MatchModel.fromMap(String id, Map<String, dynamic> map) {
    var positions = <Point<int>>[];
    if (map['playerPositions'] != null) {
      for (var p in map['playerPositions']) {
        positions.add(Point(p['x'] as int, p['y'] as int));
      }
    } else {
      positions = [const Point(2, 6), const Point(17, 6)];
    }

    return MatchModel(
      id: id,
      players: List<String>.from(map['players'] ?? []),
      grid: List<int>.from(map['grid'] ?? []),
      grid2: map['grid2'] != null ? List<int>.from(map['grid2']) : null,
      activePlayerIndex: map['activePlayerIndex'] ?? 0,
      gameStatus: map['gameStatus'] ?? 'waiting',
      winnerId: map['winnerId'],
      lastMove: map['lastMove'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.parse(map['createdAt'].toString()))
          : DateTime.now(),
      playerPositions: positions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'players': players,
      'grid': grid,
      'grid2': grid2,
      'activePlayerIndex': activePlayerIndex,
      'gameStatus': gameStatus,
      'winnerId': winnerId,
      'lastMove': lastMove,
      'createdAt': createdAt,
      'playerPositions': playerPositions.map((p) => {'x': p.x, 'y': p.y}).toList(),
    };
  }

  List<int> getGridForPlayer(int playerIndex) {
    return playerIndex == 0 ? grid : grid2;
  }

  List<List<int>> getGrid2D(int rows, int cols, {int playerIndex = 0}) {
    List<List<int>> grid2D = [];
    final totalCells = rows * cols;
    final sourceGrid = getGridForPlayer(playerIndex);

    List<int> safeGrid = List.from(sourceGrid);
    if (safeGrid.length < totalCells) {
      safeGrid.addAll(List.filled(totalCells - safeGrid.length, 0));
    } else if (safeGrid.length > totalCells) {
      safeGrid = safeGrid.sublist(0, totalCells);
    }

    for (int i = 0; i < rows; i++) {
      grid2D.add(safeGrid.sublist(i * cols, (i + 1) * cols));
    }
    return grid2D;
  }

  static List<int> flattenGrid(List<List<int>> grid2D) {
    return grid2D.expand((row) => row).toList();
  }
}
