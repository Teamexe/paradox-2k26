import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
<<<<<<< HEAD
import 'package:paradox_2k26/commit-game/constants.dart';
import 'package:paradox_2k26/models/match_model.dart';
import 'package:paradox_2k26/commit-game/map_generator.dart';
=======
import 'package:paradox/commit-game/constants.dart';
import 'package:paradox/models/match_model.dart';
import 'package:paradox/commit-game/map_generator.dart';
>>>>>>> main

class MatchmakingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> joinQueue(String userId) async {
    await _firestore.collection('waiting_room').doc('queue').set({
      userId: FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await findOpponent(userId);
  }

  Future<void> findOpponent(String userId) async {
    final queueRef = _firestore.collection('waiting_room').doc('queue');

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(queueRef);
        if (!snapshot.exists) return;

        final data = snapshot.data() as Map<String, dynamic>;
        final userIds = data.keys.toList();
        userIds.remove(userId);

        if (userIds.isNotEmpty) {
          final opponentId = userIds.first;
          final matchRef = _firestore.collection('matches').doc();

          final mapGen = MapGenerator(seed: DateTime.now().millisecondsSinceEpoch);
          final grid = mapGen.generateMazeGrid(gridRows, gridCols);
          final flatGrid = MatchModel.flattenGrid(grid);

          final p1StartIdx = 6 * gridCols + 2;
          final p2StartIdx = 6 * gridCols + 17;
          if (p1StartIdx < flatGrid.length) flatGrid[p1StartIdx] = 0;
          if (p2StartIdx < flatGrid.length) flatGrid[p2StartIdx] = 0;

          final match = MatchModel(
            id: matchRef.id,
            players: [opponentId, userId],
            grid: flatGrid,
            activePlayerIndex: 0,
            gameStatus: 'playing',
            createdAt: DateTime.now(),
            playerPositions: [const Point(2, 6), const Point(17, 6)],
          );

          transaction.set(matchRef, match.toMap());

          transaction.update(queueRef, {
            userId: FieldValue.delete(),
            opponentId: FieldValue.delete(),
          });
        }
      });
    } catch (e) {
      // silently fail
    }
  }

  Future<void> leaveQueue(String userId) async {
    await _firestore.collection('waiting_room').doc('queue').update({
      userId: FieldValue.delete(),
    });
  }

  Future<void> cleanupOldMatches(String userId) async {
    try {
      final oldMatches = await _firestore
          .collection('matches')
          .where('players', arrayContains: userId)
          .get();

      for (final doc in oldMatches.docs) {
        final status = doc.data()['gameStatus'] as String?;
        if (status == 'finished' || status == 'abandoned') {
          await doc.reference.delete();
        }
      }
    } catch (e) {
      // silently fail
    }
  }
}
