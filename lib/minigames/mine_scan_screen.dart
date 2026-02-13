import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

// Data model for each cell
class Cell {
  bool isMine;
  bool isRevealed;
  bool isFlagged;
  int neighborCount;

  Cell({
    this.isMine = false,
    this.isRevealed = false,
    this.isFlagged = false,
    this.neighborCount = 0,
  });
}

class MineScanScreen extends StatefulWidget {
  final bool isLevelMode;
  final Function(int)? onComplete;

  const MineScanScreen({super.key, this.isLevelMode = false, this.onComplete});

  @override
  State<MineScanScreen> createState() => _MineScanScreenState();
}

class _MineScanScreenState extends State<MineScanScreen> {
  int size = 8;
  int totalMines = 10;
  late List<List<Cell>> grid;
  bool gameOver = false;
  bool won = false;
  int timeLeft = 180;
  Timer? _timer;
  bool timerActive = false;

  @override
  void initState() {
    super.initState();
    _initBoard();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initBoard() {
    setState(() {
      gameOver = false;
      won = false;
      timeLeft = 180;
      timerActive = false;
      _timer?.cancel();

      // 1. Initialize empty grid
      grid = List.generate(size, (_) => List.generate(size, (_) => Cell()));

      // 2. Plant Mines
      int planted = 0;
      Random rand = Random();
      while (planted < totalMines) {
        int r = rand.nextInt(size);
        int c = rand.nextInt(size);
        if (!grid[r][c].isMine) {
          grid[r][c].isMine = true;
          planted++;
        }
      }

      // 3. Calculate Neighbors
      for (int r = 0; r < size; r++) {
        for (int c = 0; c < size; c++) {
          if (grid[r][c].isMine) continue;
          int count = 0;
          for (int i = -1; i <= 1; i++) {
            for (int j = -1; j <= 1; j++) {
              int nr = r + i;
              int nc = c + j;
              if (nr >= 0 && nr < size && nc >= 0 && nc < size) {
                if (grid[nr][nc].isMine) count++;
              }
            }
          }
          grid[r][c].neighborCount = count;
        }
      }
    });
  }

  void _startTimer() {
    timerActive = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          gameOver = true;
          _timer?.cancel();
        }
      });
    });
  }

  void _revealCell(int r, int c) {
    if (gameOver || won || grid[r][c].isRevealed || grid[r][c].isFlagged)
      return;

    if (!timerActive) _startTimer();

    setState(() {
      if (grid[r][c].isMine) {
        gameOver = true;
        _timer?.cancel();
        _revealAllMines();
      } else {
        _recursiveReveal(r, c);
        _checkWin();
      }
    });
  }

  void _recursiveReveal(int r, int c) {
    if (r < 0 || r >= size || c < 0 || c >= size) return;
    if (grid[r][c].isRevealed || grid[r][c].isMine || grid[r][c].isFlagged)
      return;

    grid[r][c].isRevealed = true;

    if (grid[r][c].neighborCount == 0) {
      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          _recursiveReveal(r + i, c + j);
        }
      }
    }
  }

  void _toggleFlag(int r, int c) {
    if (gameOver || won || grid[r][c].isRevealed) return;
    setState(() {
      grid[r][c].isFlagged = !grid[r][c].isFlagged;
    });
  }

  void _revealAllMines() {
    for (var row in grid) {
      for (var cell in row) {
        if (cell.isMine) cell.isRevealed = true;
      }
    }
  }

  void _showRulesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF050A14),
            border: Border.all(color: const Color(0xFF00F2FF), width: 2),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00F2FF).withOpacity(0.2),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "MISSION BRIEFING",
                style: TextStyle(
                  color: Color(0xFF00F2FF),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const Divider(color: Color(0xFF00F2FF), thickness: 1, height: 30),
              _ruleRow("☢", "Avoid the mines! One click ends the mission."),
              _ruleRow(
                "1-8",
                "Numbers show how many mines are touching that cell.",
              ),
              _ruleRow(
                "⚑",
                "Long-press a cell to place a flag on suspected mines.",
              ),
              _ruleRow("⚡", "Clear all safe cells to breach the system."),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF00F2FF)),
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                ),
                child: const Text(
                  "UNDERSTOOD",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ruleRow(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            icon,
            style: const TextStyle(
              color: Color(0xFF00F2FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _checkWin() {
    int unrevealedSafeCells = 0;
    for (var row in grid) {
      for (var cell in row) {
        if (!cell.isMine && !cell.isRevealed) unrevealedSafeCells++;
      }
    }
    if (unrevealedSafeCells == 0) {
      won = true;
      _timer?.cancel();
      if (widget.isLevelMode && widget.onComplete != null) {
        widget.onComplete!(180 - timeLeft);
      }
    }
  }

  int get _flagsUsed => grid.expand((e) => e).where((e) => e.isFlagged).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050A14),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                _buildStats(),
                Expanded(child: _buildBoard()),
                _buildInstructions(),
                const SizedBox(height: 20),
              ],
            ),
            if (gameOver || won) _buildOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Empty SizedBox to balance the layout
          const SizedBox(width: 48),
          Column(
            children: [
              Text(
                "MINE SCAN",
                style: TextStyle(
                  color: const Color(0xFF00F2FF),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: const Color(0xFF00F2FF).withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              const Text(
                "DATA BREACH",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          // The Help Button
          IconButton(
            icon: const Icon(
              Icons.help_outline,
              color: Color(0xFF00F2FF),
              size: 28,
            ),
            onPressed: () => _showRulesDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF00F2FF).withOpacity(0.1),
        border: Border.all(color: const Color(0xFF00F2FF)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statText("MINES: ", "${totalMines - _flagsUsed}"),
          _statText("TIME: ", "$timeLeft s", critical: timeLeft < 20),
        ],
      ),
    );
  }

  Widget _statText(String label, String value, {bool critical = false}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF00F2FF), fontSize: 16),
        ),
        Text(
          value,
          style: TextStyle(
            color: critical ? Colors.red : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildBoard() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(8),
        color: Colors.black,
        child: AspectRatio(
          aspectRatio: 1,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: size,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: size * size,
            itemBuilder: (context, index) {
              int r = index ~/ size;
              int c = index % size;
              Cell cell = grid[r][c];

              return GestureDetector(
                onTap: () => _revealCell(r, c),
                onLongPress: () => _toggleFlag(r, c),
                child: Container(
                  decoration: BoxDecoration(
                    color: cell.isRevealed
                        ? Colors.black
                        : const Color(0xFF1A1A1A),
                    border: Border.all(
                      color: cell.isRevealed ? Colors.white10 : Colors.white24,
                    ),
                  ),
                  child: _buildCellContent(cell),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCellContent(Cell cell) {
    if (cell.isFlagged && !cell.isRevealed) {
      return const Center(
        child: Text("⚑", style: TextStyle(color: Colors.orange, fontSize: 18)),
      );
    }
    if (!cell.isRevealed) return const SizedBox.shrink();
    if (cell.isMine) {
      return const Center(
        child: Text("☢", style: TextStyle(color: Colors.red, fontSize: 18)),
      );
    }
    if (cell.neighborCount > 0) {
      return Center(
        child: Text(
          "${cell.neighborCount}",
          style: TextStyle(
            color: _getNeighborColor(cell.neighborCount),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Color _getNeighborColor(int count) {
    switch (count) {
      case 1:
        return const Color(0xFF00F2FF);
      case 2:
        return const Color(0xFF00FF88);
      case 3:
        return Colors.orange;
      case 4:
        return Colors.purpleAccent;
      default:
        return Colors.red;
    }
  }

  Widget _buildInstructions() {
    return const Padding(
      padding: EdgeInsets.only(top: 10),
      child: Text(
        "TAP TO SCAN • LONG PRESS TO FLAG",
        style: TextStyle(color: Colors.white24, fontSize: 10),
      ),
    );
  }

  Widget _buildOverlay() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        color: Colors.black,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              won ? "SYSTEM CLEARED" : "SYSTEM BREACHED",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: won ? const Color(0xFF00FF88) : const Color(0xFFFF003C),
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _initBoard,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                side: BorderSide(
                  color: won
                      ? const Color(0xFF00FF88)
                      : const Color(0xFFFF003C),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              child: const Text(
                "RETRY MISSION",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
