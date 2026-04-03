import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CellState { empty, path, start, clicked, wrong }

class PathfinderScreen extends StatefulWidget {
  final bool isLevelMode;
  final Function(double)? onComplete;

  const PathfinderScreen({
    super.key,
    this.isLevelMode = false,
    this.onComplete,
  });

  @override
  State<PathfinderScreen> createState() => _PathfinderScreenState();
}

class _PathfinderScreenState extends State<PathfinderScreen> {
  // Game Config
  final int gridSize = 15;
  final int pathLength = 32; // Hard level
  final Duration revealDuration = const Duration(seconds: 6);
  final double totalTime = 90.0;

  // State
  List<CellState> grid = [];
  List<int> path = [];
  int currentProgress = 0;
  double timeLeft = 90.0;
  bool isMemorizing = true;
  bool gameOver = false;
  bool won = false;
  Timer? gameTimer;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  void _startNewGame() {
    setState(() {
      grid = List.generate(gridSize * gridSize, (_) => CellState.empty);
      path = [];
      currentProgress = 1; // Start from index 1 (0 is the 'Start' cell)
      timeLeft = totalTime;
      isMemorizing = true;
      gameOver = false;
      won = false;
    });
    _generatePath();
    _revealPath();
  }

  void _generatePath() {
    Random rand = Random();
    int cur = rand.nextInt(gridSize * gridSize);
    path = [cur];
    Set<int> visited = {cur};

    for (int i = 0; i < pathLength - 1; i++) {
      int r = cur ~/ gridSize;
      int c = cur % gridSize;
      List<int> neighbors = [];

      if (r > 0) neighbors.add(cur - gridSize);
      if (r < gridSize - 1) neighbors.add(cur + gridSize);
      if (c > 0) neighbors.add(cur - 1);
      if (c < gridSize - 1) neighbors.add(cur + 1);

      neighbors.removeWhere((n) => visited.contains(n));
      if (neighbors.isEmpty) break;

      cur = neighbors[rand.nextInt(neighbors.length)];
      path.add(cur);
      visited.add(cur);
    }
  }

  Future<void> _revealPath() async {
    // Show the path step by step
    int stepDelay = revealDuration.inMilliseconds ~/ path.length;

    for (int i = 0; i < path.length; i++) {
      if (!mounted) return;
      setState(() {
        grid[path[i]] = (i == 0) ? CellState.start : CellState.path;
      });
      await Future.delayed(Duration(milliseconds: stepDelay));
    }

    // Wait 1 second then hide path
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    setState(() {
      for (int i = 1; i < path.length; i++) {
        grid[path[i]] = CellState.empty; // Hide everything but start
      }
      isMemorizing = false;
    });

    _startTimer();
  }

  void _startTimer() {
    gameTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft -= 0.1;
        } else {
          _endGame(false);
        }
      });
    });
  }

  void _handleCellClick(int index) {
    if (isMemorizing || gameOver || won) return;
    if (index == path[currentProgress - 1])
      return; // Prevent double clicking current

    if (index == path[currentProgress]) {
      // Correct Step
      setState(() {
        grid[index] = CellState.clicked;
        currentProgress++;
      });
      HapticFeedback.lightImpact();

      if (currentProgress == path.length) {
        _endGame(true);
      }
    } else {
      // Wrong Step
      setState(() {
        grid[index] = CellState.wrong;
        // Reveal full path as penalty
        for (int pIdx in path) {
          if (grid[pIdx] == CellState.empty) grid[pIdx] = CellState.path;
        }
      });
      _endGame(false);
    }
  }

  void _endGame(bool success) {
    gameTimer?.cancel();
    HapticFeedback.heavyImpact();
    setState(() {
      if (success) {
        won = success;
      } else {
        gameOver = true;
      }
    });

    if (success && widget.isLevelMode && widget.onComplete != null) {
      widget.onComplete!(totalTime - timeLeft);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            left: -100,
            child: _blurGlow(const Color(0xFFBC13FE)),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: _blurGlow(const Color(0xFF00F3FF)),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildTimerBar(),
                const SizedBox(height: 20),
                Expanded(child: _buildGrid()),
                _buildStatusFooter(),
                const SizedBox(height: 20),
              ],
            ),
          ),
          if (gameOver || won) _buildOverlay(),
        ],
      ),
    );
  }

  Widget _blurGlow(Color color) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.15),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 0),
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
                  "PATH MAPPER ${widget.isLevelMode ? '(Level 6)' : ''}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  isMemorizing ? "MEMORIZING FREQUENCY..." : "REPLICATE SIGNAL",
                  style: TextStyle(
                    color: isMemorizing
                        ? const Color(0xFFBC13FE)
                        : const Color(0xFF00F3FF),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildTimerBar() {
    return Container(
      width: double.infinity,
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: timeLeft / totalTime,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFBC13FE), Color(0xFF00F3FF)],
            ),
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00F3FF).withOpacity(0.5),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double boardSize = min(constraints.maxWidth, constraints.maxHeight);
          return SizedBox(
            width: boardSize,
            height: boardSize,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: gridSize * gridSize,
              itemBuilder: (context, index) => _buildCell(index),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCell(int index) {
    CellState state = grid[index];
    Color color;
    BoxShadow? glow;

    switch (state) {
      case CellState.start:
        color = Colors.white;
        glow = const BoxShadow(color: Colors.white, blurRadius: 10);
        break;
      case CellState.path:
        color = const Color(0xFF00F3FF);
        glow = const BoxShadow(color: Color(0xFF00F3FF), blurRadius: 8);
        break;
      case CellState.clicked:
        color = const Color(0xFF0AFF0A);
        glow = const BoxShadow(color: Color(0xFF0AFF0A), blurRadius: 8);
        break;
      case CellState.wrong:
        color = const Color(0xFFFF003C);
        glow = const BoxShadow(color: Color(0xFFFF003C), blurRadius: 15);
        break;
      default:
        color = Colors.white.withOpacity(0.05);
        glow = null;
    }

    return GestureDetector(
      onTapDown: (_) => _handleCellClick(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
          boxShadow: glow != null ? [glow] : [],
        ),
        child: state == CellState.start
            ? const Center(
                child: Text(
                  "S",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildStatusFooter() {
    return Text(
      "PROGRESS: $currentProgress / ${path.length}",
      style: const TextStyle(
        color: Colors.white24,
        letterSpacing: 4,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildOverlay() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        color: Colors.black87,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              won ? "SIGNAL RESTORED" : "PATH LOST",
              style: TextStyle(
                color: won ? const Color(0xFF0AFF0A) : const Color(0xFFFF003C),
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _startNewGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                side: BorderSide(
                  color: won
                      ? const Color(0xFF0AFF0A)
                      : const Color(0xFFFF003C),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
              ),
              child: const Text(
                "RETRY LINK",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
