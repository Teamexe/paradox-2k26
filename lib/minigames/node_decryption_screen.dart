import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NodeDecryptionScreen extends StatefulWidget {
  final bool isLevelMode;
  final Function(int)? onComplete;

  const NodeDecryptionScreen({
    super.key,
    this.isLevelMode = false,
    this.onComplete,
  });

  @override
  State<NodeDecryptionScreen> createState() => _NodeDecryptionScreenState();
}

class _NodeDecryptionScreenState extends State<NodeDecryptionScreen> {
  final int gridSize = 4;
  List<int> sequence = [];
  List<int> userSequence = [];

  bool isShowingSequence = false;
  bool gameOver = false;
  bool won = false;
  int currentLevel = 1;
  int maxLevels = 10; // 10 levels to win

  int? activeNode;
  Timer? inputTimer;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  @override
  void dispose() {
    inputTimer?.cancel();
    super.dispose();
  }

  void _startNewGame() {
    setState(() {
      currentLevel = 1;
      sequence = [];
      userSequence = [];
      gameOver = false;
      won = false;
    });
    _nextLevel();
  }

  Future<void> _nextLevel() async {
    inputTimer?.cancel();
    setState(() {
      isShowingSequence = true;
      userSequence = [];
      sequence.add(Random().nextInt(gridSize * gridSize));
    });

    await Future.delayed(const Duration(milliseconds: 800));

    // --- SPEED CALCULATION ---
    // Level 1: 500ms flash, 200ms pause
    // Level 10: 150ms flash, 50ms pause (Very Fast!)
    int flashDuration = max(150, 500 - (currentLevel * 40));
    int pauseDuration = max(50, 200 - (currentLevel * 15));

    for (int nodeIndex in sequence) {
      if (!mounted) return;
      setState(() => activeNode = nodeIndex);
      HapticFeedback.selectionClick();

      await Future.delayed(Duration(milliseconds: flashDuration));
      setState(() => activeNode = null);
      await Future.delayed(Duration(milliseconds: pauseDuration));
    }

    setState(() => isShowingSequence = false);
    _startInputTimer();
  }

  void _startInputTimer() {
    inputTimer?.cancel();
    // 2 second limit to press the next node
    inputTimer = Timer(const Duration(milliseconds: 2000), () {
      if (!won && !gameOver && !isShowingSequence) {
        _triggerFail();
      }
    });
  }

  void _handleNodeTap(int index) {
    if (isShowingSequence || gameOver || won) return;

    inputTimer?.cancel();

    setState(() {
      activeNode = index;
      userSequence.add(index);
    });

    if (userSequence.last != sequence[userSequence.length - 1]) {
      _triggerFail();
    } else {
      HapticFeedback.lightImpact();

      // Brief visual feedback for tap
      Timer(const Duration(milliseconds: 150), () {
        setState(() => activeNode = null);

        if (userSequence.length == sequence.length) {
          if (currentLevel >= maxLevels) {
            setState(() => won = true);
            if (widget.onComplete != null)
              widget.onComplete!(currentLevel * 10);
          } else {
            setState(() => currentLevel++);
            _nextLevel();
          }
        } else {
          _startInputTimer(); // Reset timer for next tap
        }
      });
    }
  }

  void _triggerFail() {
    HapticFeedback.heavyImpact();
    setState(() {
      gameOver = true;
      activeNode = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F0A),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                _buildProgressBar(),
                const Spacer(),
                _buildGrid(),
                const Spacer(),
                _buildStatusText(),
                const SizedBox(height: 40),
              ],
            ),
            if (gameOver || won) _buildOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          "NODE DECRYPTION",
          style: TextStyle(
            color: Color(0xFF39FF14),
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        Text(
          "TRANSMISSION SPEED: ${110 - (currentLevel * 10)}%",
          style: const TextStyle(color: Colors.white38, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      height: 6,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: currentLevel / maxLevels,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF39FF14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF39FF14).withOpacity(0.6),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: 16,
        itemBuilder: (context, index) {
          bool isActive = activeNode == index;
          return GestureDetector(
            onTapDown: (_) => _handleNodeTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 50),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF39FF14) : Colors.black,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? Colors.white : const Color(0xFF1A3311),
                  width: 2,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: const Color(0xFF39FF14).withOpacity(1),
                          blurRadius: 20,
                        ),
                      ]
                    : [],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusText() {
    String text = isShowingSequence ? "RECEIVING DATA..." : "REPEAT PATTERN";
    if (gameOver) text = "CONNECTION LOST";
    return Text(
      text,
      style: TextStyle(
        color: isShowingSequence ? Colors.orange : const Color(0xFF39FF14),
        letterSpacing: 2,
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
              won ? "ACCESS GRANTED" : "DECRYPTION FAILED",
              style: TextStyle(
                color: won ? const Color(0xFF39FF14) : Colors.red,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Sequence Length: $currentLevel",
              style: const TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 40),
            TextButton(
              onPressed: _startNewGame,
              style: TextButton.styleFrom(
                side: BorderSide(
                  color: won ? const Color(0xFF39FF14) : Colors.red,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              child: Text(
                won ? "CONTINUE" : "RETRY",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
