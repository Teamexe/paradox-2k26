import 'dart:async';
import 'dart:math' as math;
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/collisions.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';

// ================= COLORS & CONSTANTS =================
const Color bloodRed = Color(0xFF670715);
const Color toxicGreen = Color(0xFF00FF64);
const Color shadowBlack = Color(0xFF141419);
const double groundHeight = 50.0;

// ================= GAME SCREEN (UI & Hardware) =================
class VoiceFlappyScreen extends StatefulWidget {
  const VoiceFlappyScreen({super.key});

  @override
  State<VoiceFlappyScreen> createState() => _VoiceFlappyScreenState();
}

class _VoiceFlappyScreenState extends State<VoiceFlappyScreen> {
  late VoiceFlappyGame game;
  double _currentDb = 0;
  double threshold = 75; // Adjust sensitivity here
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSubscription;

  @override
  void initState() {
    super.initState();
    game = VoiceFlappyGame();
    _initVoiceControl();
  }

  @override
  void dispose() {
    _noiseSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initVoiceControl() async {
    // 1. Request Permission
    var status = await Permission.microphone.status;
    if (status.isDenied) {
      status = await Permission.microphone.request();
    }

    if (status.isGranted) {
      try {
        _noiseMeter = NoiseMeter();
        _noiseSubscription = _noiseMeter?.noise.listen((reading) {
          if (!mounted) return;

          setState(() {
            _currentDb = reading.maxDecibel;
          });

          // 2. Trigger Jump in Game
          if (reading.maxDecibel > threshold && !game.isGameOver) {
            game.bird.flap();
          }
        }, onError: (error) => print("Noise Error: $error"));
      } catch (e) {
        print("Could not start noise meter: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GameWidget(game: game),

          // Debug DB Meter
          Positioned(
            top: 120,
            right: 100,

            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "VOL: ${_currentDb.toStringAsFixed(1)} / THR: $threshold",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Score Overlay
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: ValueListenableBuilder<int>(
                valueListenable: game.scoreNotifier,
                builder: (context, value, child) {
                  return Text(
                    '.EXE - $value',
                    style: const TextStyle(
                      color: bloodRed,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  );
                },
              ),
            ),
          ),

          // Start / Game Over Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: ValueListenableBuilder<bool>(
                valueListenable: game.isGameOverNotifier,
                builder: (context, isDead, child) {
                  return isDead
                      ? const Text(
                          "TAP SCREEN TO RESTART",
                          style: TextStyle(
                            color: toxicGreen,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const Text(
                          "SHOUT TO FLY",
                          style: TextStyle(color: Colors.white24, fontSize: 18),
                        );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= GAME ENGINE =================
class VoiceFlappyGame extends FlameGame
    with HasCollisionDetection, TapDetector {
  late Bird bird;
  final ValueNotifier<int> scoreNotifier = ValueNotifier(0);
  final ValueNotifier<bool> isGameOverNotifier = ValueNotifier(false);

  double obstacleSpeed = 220;
  double spawnTimer = 0;
  bool isGameOver = false;

  @override
  Future<void> onLoad() async {
    // Background color
    add(RectangleComponent(size: size, paint: Paint()..color = shadowBlack));

    bird = Bird();
    add(bird);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    // Spawning logic
    spawnTimer += dt;
    double spawnInterval = math.max(1.2, 2.5 - (scoreNotifier.value * 0.1));

    if (spawnTimer > spawnInterval) {
      _spawnGravePillar();
      spawnTimer = 0;
    }

    // Check Ground Collision
    if (bird.position.y > size.y - groundHeight) {
      gameOver();
    }
  }

  void _spawnGravePillar() {
    double gap = math.max(160, 240 - (scoreNotifier.value * 4.0));
    add(GravePillar(x: size.x, gap: gap));
  }

  void gameOver() {
    isGameOver = true;
    isGameOverNotifier.value = true;
    pauseEngine();
  }

  @override
  void onTap() {
    if (isGameOver) {
      scoreNotifier.value = 0;
      isGameOver = false;
      isGameOverNotifier.value = false;
      children.whereType<GravePillar>().forEach((p) => p.removeFromParent());
      bird.reset(size.y / 2);
      resumeEngine();
    }
  }
}

// ================= BIRD COMPONENT =================
class Bird extends PositionComponent
    with CollisionCallbacks, HasGameRef<VoiceFlappyGame> {
  double velocity = 0;
  double gravity = 1000;
  double jumpStrength = -400;

  Bird() : super(size: Vector2(40, 30), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    position = Vector2(100, gameRef.size.y / 2);
    add(RectangleHitbox());
  }

  void flap() {
    velocity = jumpStrength;
  }

  void reset(double startY) {
    position.y = startY;
    velocity = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    velocity += gravity * dt;
    position.y += velocity * dt;

    // Rotation effect
    angle = (velocity / 600).clamp(-0.5, 0.5);

    // Keep on screen top
    if (position.y < 0) position.y = 0;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = bloodRed;
    canvas.drawRect(size.toRect(), paint);

    // Eye
    canvas.drawCircle(
      Offset(size.x - 10, 10),
      5,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(Offset(size.x - 8, 10), 2, Paint()..color = Colors.black);
  }
}

// ================= OBSTACLE COMPONENT =================
class GravePillar extends PositionComponent
    with CollisionCallbacks, HasGameRef<VoiceFlappyGame> {
  final double gap;
  bool scored = false;
  late double topHeight;

  GravePillar({required double x, required this.gap})
    : super(position: Vector2(x, 0), size: Vector2(70, 0));

  @override
  Future<void> onLoad() async {
    size.y = gameRef.size.y;
    double minH = 80;
    double maxH = gameRef.size.y - gap - minH - groundHeight;
    topHeight = minH + math.Random().nextDouble() * (maxH - minH);

    add(
      RectangleHitbox(
        position: Vector2(0, 0),
        size: Vector2(size.x, topHeight),
      ),
    );
    add(
      RectangleHitbox(
        position: Vector2(0, topHeight + gap),
        size: Vector2(size.x, gameRef.size.y - (topHeight + gap)),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= gameRef.obstacleSpeed * dt;

    if (!scored && position.x + size.x < gameRef.bird.position.x) {
      scored = true;
      gameRef.scoreNotifier.value++;
    }

    if (position.x < -size.x) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFF404045);
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw Pillar Boxes
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, topHeight), paint);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, topHeight), borderPaint);

    canvas.drawRect(
      Rect.fromLTWH(0, topHeight + gap, size.x, gameRef.size.y),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, topHeight + gap, size.x, gameRef.size.y),
      borderPaint,
    );

    // Emoji Decoration
    const textStyle = TextStyle(fontSize: 24);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = const TextSpan(text: '💀', style: textStyle);
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.x / 4, topHeight - 40));
    textPainter.paint(canvas, Offset(size.x / 4, topHeight + gap + 10));
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Bird) {
      gameRef.gameOver();
    }
  }
}
