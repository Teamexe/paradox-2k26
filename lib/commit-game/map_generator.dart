import 'dart:math';
import 'package:paradox_2k26/commit-game/constants.dart';

class MapGenerator {
  final Random _random;

  MapGenerator({int? seed}) : _random = Random(seed);

  List<List<int>> generateMazeGrid(int rows, int cols) {
    final grid = List.generate(rows, (_) => List.generate(cols, (_) => 0));
    _generateCaves(grid, rows, cols);

    for (int c = 0; c < cols; c++) {
      grid[0][c] = 0;
      grid[rows - 1][c] = 0;
    }

    return grid;
  }

  void _generateCaves(List<List<int>> grid, int rows, int cols) {
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        if (_random.nextDouble() < 0.45) {
          grid[y][x] = _random.nextInt(maxCommits) + 1;
        } else {
          grid[y][x] = 0;
        }
      }
    }

    for (int i = 0; i < 3; i++) {
      _smoothMap(grid, rows, cols);
    }

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        if (grid[y][x] > 0) {
          final roll = _random.nextDouble();
          if (roll < 0.35) {
            grid[y][x] = 1;
          } else if (roll < 0.65) {
            grid[y][x] = 2;
          } else if (roll < 0.85) {
            grid[y][x] = 3;
          } else {
            grid[y][x] = 4;
          }
        }
      }
    }
  }

  void _smoothMap(List<List<int>> grid, int rows, int cols) {
    final newGrid = List<List<int>>.from(grid.map((row) => List<int>.from(row)));

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        int wallNeighbors = _countWallNeighbors(grid, x, y, rows, cols);
        if (wallNeighbors > 4) {
          newGrid[y][x] = grid[y][x] > 0 ? grid[y][x] : 1;
        } else if (wallNeighbors < 3) {
          newGrid[y][x] = 0;
        }
      }
    }
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        grid[y][x] = newGrid[y][x];
      }
    }
  }

  int _countWallNeighbors(List<List<int>> grid, int x, int y, int rows, int cols) {
    int count = 0;
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        if (i == 0 && j == 0) continue;
        int neighborX = x + i;
        int neighborY = y + j;

        if (neighborX < 0 || neighborY < 0 || neighborX >= cols || neighborY >= rows) {
          count++;
        } else if (grid[neighborY][neighborX] > 0) {
          count++;
        }
      }
    }
    return count;
  }
}
