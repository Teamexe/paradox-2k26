import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CoreBreachScreen extends StatefulWidget {
  final bool isLevelMode;
  final Function(int)? onComplete;

  const CoreBreachScreen({
    super.key,
    this.isLevelMode = false,
    this.onComplete,
  });

  @override
  State<CoreBreachScreen> createState() => _CoreBreachScreenState();
}

class _CoreBreachScreenState extends State<CoreBreachScreen>
    with SingleTickerProviderStateMixin {
  // Game State
  List<double> heatLevels = [0.0, 0.0, 0.0, 0.0];
  String targetCode = "";
  String userEntry = "";
  int codesCompleted = 0;
  final int totalCodesRequired = 5;

  bool gameOver = false;
  bool won = false;
  Timer? gameTick;

  // Animation for screen shake
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _startNewGame();
  }

  @override
  void dispose() {
    gameTick?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  void _startNewGame() {
    setState(() {
      heatLevels = [0.0, 0.2, 0.1, 0.3];
      codesCompleted = 0;
      userEntry = "";
      gameOver = false;
      won = false;
      _generateNewCode();
    });

    // Main Game Loop (Every 50ms)
    gameTick?.cancel();
    gameTick = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      _updateHeat();
    });
  }

  void _generateNewCode() {
    const chars = "0123456789ABCDEF";
    Random r = Random();
    targetCode = List.generate(
      4,
      (index) => chars[r.nextInt(chars.length)],
    ).join();
  }

  void _updateHeat() {
    if (gameOver || won) return;

    setState(() {
      // Heat rises faster as you progress
      double riseAmount = 0.004 + (codesCompleted * 0.002);

      bool critical = false;
      for (int i = 0; i < heatLevels.length; i++) {
        heatLevels[i] +=
            riseAmount * (1.0 + (i * 0.1)); // Slightly different speeds
        if (heatLevels[i] >= 0.8) critical = true;

        if (heatLevels[i] >= 1.0) {
          _triggerFail("CORE MELTDOWN");
        }
      }

      if (critical) {
        _shakeController.repeat(reverse: true);
      } else {
        _shakeController.stop();
      }
    });
  }

  void _ventHeat(int index) {
    if (gameOver || won) return;
    HapticFeedback.mediumImpact();
    setState(() {
      heatLevels[index] = 0.0;
    });
  }

  void _showRulesDialog(BuildContext context) {
    // Pause game logic while reading rules if desired,
    // though in a "Boss Level" sometimes it's cooler if the timer keeps running!
    // For now, let's just show the info.

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0208),
            border: Border.all(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 20),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "FINAL MISSION BRIEFING",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const Divider(color: Colors.red, thickness: 1, height: 30),
              _ruleRow(
                Icons.thermostat,
                "HEAT MANAGEMENT",
                "The 4 side bars are overheating. Tap them constantly to vent heat to 0%.",
              ),
              _ruleRow(
                Icons.keyboard,
                "OVERRIDE CODE",
                "Enter the 4-digit Hex code shown in the center using the keypad.",
              ),
              _ruleRow(
                Icons.warning_amber_rounded,
                "CRITICAL FAILURE",
                "If any stabilizer hits 100%, the core meltdowns and you fail.",
              ),
              _ruleRow(
                Icons.verified_user,
                "OBJECTIVE",
                "Successfully enter 5 codes to bypass the final security layer.",
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                ),
                child: const Text(
                  "I'M READY",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleKeyPress(String key) {
    if (gameOver || won) return;
    HapticFeedback.lightImpact();

    setState(() {
      userEntry += key;
      if (userEntry.length == 4) {
        if (userEntry == targetCode) {
          codesCompleted++;
          userEntry = "";
          if (codesCompleted >= totalCodesRequired) {
            _triggerWin();
          } else {
            _generateNewCode();
          }
        } else {
          userEntry = ""; // Reset on wrong code
          HapticFeedback.vibrate();
        }
      }
    });
  }

  void _triggerWin() {
    setState(() {
      won = true;
      gameTick?.cancel();
    });
    if (widget.onComplete != null) widget.onComplete!(500);
  }

  void _triggerFail(String reason) {
    setState(() {
      gameOver = true;
      gameTick?.cancel();
    });
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0208),
      body: AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          double offset = _shakeController.value * 4.0;
          return Transform.translate(
            offset: Offset(offset, offset),
            child: child,
          );
        },
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: Row(
                      children: [
                        _buildStabilizer(0),
                        _buildStabilizer(1),
                        Expanded(child: _buildCenterCore()),
                        _buildStabilizer(2),
                        _buildStabilizer(3),
                      ],
                    ),
                  ),
                  _buildKeypad(),
                  const SizedBox(height: 20),
                ],
              ),
              if (gameOver || won) _buildOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Balance spacer
          const SizedBox(width: 48),
          Column(
            children: [
              const Text(
                "CORE BREACH",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              Text(
                "STABILIZERS ATTACHED: ${codesCompleted}/$totalCodesRequired",
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(
              Icons.help_outline,
              color: Colors.redAccent,
              size: 30,
            ),
            onPressed: () => _showRulesDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _ruleRow(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.redAccent, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStabilizer(int index) {
    double level = heatLevels[index];
    Color color = Color.lerp(Colors.orange, Colors.red, level)!;

    return GestureDetector(
      onTapDown: (_) => _ventHeat(index),
      child: Container(
        width: 40,
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 50),
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.5 * level,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.5), blurRadius: 10),
                ],
              ),
            ),
            const Positioned(
              top: 10,
              child: Icon(Icons.flash_on, color: Colors.white24, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterCore() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "OVERRIDE CODE",
          style: TextStyle(color: Colors.white54, fontSize: 10),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.purpleAccent, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.purpleAccent.withOpacity(0.3),
                blurRadius: 20,
              ),
            ],
          ),
          child: Text(
            targetCode,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
              fontFamily: 'monospace',
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            bool filled = userEntry.length > index;
            return Container(
              width: 15,
              height: 15,
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: filled ? Colors.purpleAccent : Colors.transparent,
                border: Border.all(color: Colors.purpleAccent),
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildKeypad() {
    List<String> keys = [
      "7",
      "8",
      "9",
      "A",
      "4",
      "5",
      "6",
      "B",
      "1",
      "2",
      "3",
      "C",
      "D",
      "0",
      "E",
      "F",
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.5,
        ),
        itemCount: keys.length,
        itemBuilder: (context, index) {
          return ElevatedButton(
            onPressed: () => _handleKeyPress(keys[index]),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A1A),
              side: const BorderSide(color: Colors.white10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: Text(
              keys[index],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
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
              won ? "SYSTEM BREACHED" : "CORE OVERFLOW",
              style: TextStyle(
                color: won ? Colors.purpleAccent : Colors.red,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              won ? "ALL SECURITY LAYERS BYPASSED" : "CRITICAL FAILURE",
              style: const TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _startNewGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: won ? Colors.purpleAccent : Colors.red,
              ),
              child: Text(
                won ? "REPLAY FINALE" : "RETRY INFILTRATION",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
