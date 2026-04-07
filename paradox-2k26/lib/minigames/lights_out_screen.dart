import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class LightsOutScreen extends StatefulWidget {
  final bool isLevelMode;
  final Function(int)? onComplete;

  const LightsOutScreen({super.key, this.isLevelMode = false, this.onComplete});

  @override
  State<LightsOutScreen> createState() => _LightsOutScreenState();
}

class _LightsOutScreenState extends State<LightsOutScreen> {
  int size = 5;
  late List<List<bool>> grid;
  int moves = 0;
  int timeLeft = 120;
  Timer? _timer;
  bool timerActive = false;
  bool won = false;
  bool failed = false;

  final Map<int, int> difficultySteps = {3: 10, 4: 20, 5: 35, 6: 60, 7: 100};

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startNewGame() {
    setState(() {
      moves = 0;
      won = false;
      failed = false;
      timeLeft = 120;
      timerActive = false;
      _timer?.cancel();

      // 1. Initialize empty grid
      grid = List.generate(size, (_) => List.generate(size, (_) => false));

      // 2. Scramble logic
      int scrambleMoves = difficultySteps[size] ?? 30;
      Random random = Random();

      for (int i = 0; i < scrambleMoves; i++) {
        _toggleInternal(random.nextInt(size), random.nextInt(size));
      }

      // Ensure it's not solved by luck
      if (_isSolved()) {
        _toggleInternal(0, 0);
      }
    });
  }

  void _toggleInternal(int r, int c) {
    List<List<int>> dirs = [
      [0, 0],
      [0, 1],
      [0, -1],
      [1, 0],
      [-1, 0],
    ];
    for (var dir in dirs) {
      int nr = r + dir[0];
      int nc = c + dir[1];
      if (nr >= 0 && nr < size && nc >= 0 && nc < size) {
        grid[nr][nc] = !grid[nr][nc];
      }
    }
  }

  void _handleCellClick(int r, int c) {
    if (won || failed) return;

    if (!timerActive) {
      _startTimer();
    }

    setState(() {
      _toggleInternal(r, c);
      moves++;

      if (_isSolved()) {
        won = true;
        _timer?.cancel();
        if (widget.isLevelMode && widget.onComplete != null) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            widget.onComplete!(120 - timeLeft);
          });
        }
      }
    });
  }

  bool _isSolved() {
    return grid.every((row) => row.every((cell) => !cell));
  }

  void _startTimer() {
    timerActive = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          failed = true;
          _timer?.cancel();
        }
      });
    });
  }

  String _formatTime(int s) {
    int m = s ~/ 60;
    int sec = s % 60;
    return '$m:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E011E),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                _buildStats(),
                _buildControls(),
                Expanded(child: _buildBoard()),
                const SizedBox(height: 40),
              ],
            ),
            if (won || failed) _buildOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  "LIGHTS OUT ${widget.isLevelMode ? '(Level 2)' : ''}",
                  style: const TextStyle(
                    color: Color(0xFFBC13FE),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Color(0xFFBC13FE), blurRadius: 10)],
                  ),
                ),
                const Text("Turn all lights OFF", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("Moves", moves.toString()),
          _statItem(
            "Time",
            _formatTime(timeLeft),
            color: timeLeft <= 10 ? Colors.red : null,
          ),
          _statItem(
            "On",
            grid.expand((e) => e).where((e) => e).length.toString(),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(
          value,
          style: TextStyle(
            color: color ?? const Color(0xFFE1BEE7),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!widget.isLevelMode)
            DropdownButton<int>(
              value: size,
              dropdownColor: const Color(0xFF222222),
              style: const TextStyle(color: Colors.white),
              items: [3, 4, 5, 6].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text("${value}x$value"),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => size = val);
                  _startNewGame();
                }
              },
            ),
          const SizedBox(width: 20),
          ElevatedButton(
            onPressed: _startNewGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A148C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text("RESET", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1020),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: size,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: size * size,
            itemBuilder: (context, index) {
              int r = index ~/ size;
              int c = index % size;
              bool isOn = grid[r][c];
              return GestureDetector(
                onTap: () => _handleCellClick(r, c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isOn
                        ? const Color(0xFFBC13FE)
                        : const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isOn
                          ? const Color(0xFFD1C4E9)
                          : const Color(0xFF444444),
                      width: 2,
                    ),
                    boxShadow: isOn
                        ? [
                            BoxShadow(
                              color: const Color(0xFFBC13FE).withOpacity(0.6),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                  child: isOn
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        color: Colors.black87,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              failed ? "GAME OVER" : "SOLVED!",
              style: TextStyle(
                color: failed ? Colors.red : const Color(0xFFBC13FE),
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              failed ? "Time ran out!" : "Cleared in $moves moves",
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _startNewGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: failed ? Colors.red : const Color(0xFF7B1FA2),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              child: const Text(
                "PLAY AGAIN",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
