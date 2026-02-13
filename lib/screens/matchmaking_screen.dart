import 'dart:async';
import 'package:flutter/material.dart';
import 'package:paradox/commit-game/constants.dart';
import 'package:paradox/screens/online_game_screen.dart';
import 'package:paradox/services/firebase_service.dart';
import 'package:paradox/services/matchmaking_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({super.key});

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> {
  final MatchmakingService _matchmakingService = MatchmakingService();
  final String userId = FirebaseService().currentUserId!;
  bool _joined = false;
  Timer? _pollingTimer;
  StreamSubscription? _matchSubscription;

  @override
  void initState() {
    super.initState();
    _startMatchmaking();
  }

  void _startMatchmaking() async {
    await _matchmakingService.cleanupOldMatches(userId);
    await _matchmakingService.joinQueue(userId);
    if (!mounted) return;

    setState(() {
      _joined = true;
    });

    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _matchmakingService.findOpponent(userId);
    });

    _matchSubscription = FirebaseFirestore.instance
        .collection('matches')
        .where('players', arrayContains: userId)
        .where('gameStatus', isEqualTo: 'playing')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final matchDoc = snapshot.docs.first;
        if (mounted) {
          _pollingTimer?.cancel();
          _matchSubscription?.cancel();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OnlineGameScreen(matchId: matchDoc.id),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _matchSubscription?.cancel();
    if (_joined) {
      _matchmakingService.leaveQueue(userId);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: spectralGreenColor),
            const SizedBox(height: 20),
            Text(
              'Searching for opponent...',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 18),
            ),
            const SizedBox(height: 50),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
