import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
<<<<<<< HEAD
import 'package:paradox_2k26/models/match_model.dart';
import 'package:paradox_2k26/commit-game/constants.dart';
=======
import 'package:paradox/models/match_model.dart';
import 'package:paradox/commit-game/constants.dart';
>>>>>>> main

class FirestoreGameRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<MatchModel?> listenToMatch(String matchId) {
    return _firestore.collection('matches').doc(matchId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return MatchModel.fromMap(snapshot.id, snapshot.data()!);
    });
  }

  Future<void> updateMatchStatus(String matchId, String status, {String? winnerId}) async {
    final updates = <String, dynamic>{
      'gameStatus': status,
    };
    if (winnerId != null) {
      updates['winnerId'] = winnerId;
    }
    await _firestore.collection('matches').doc(matchId).update(updates);
  }

  Future<bool> performAction(
    String matchId,
    String playerId,
    Map<String, dynamic> actionData,
  ) async {
    final matchRef = _firestore.collection('matches').doc(matchId);

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(matchRef);
        if (!snapshot.exists) throw Exception("Match not found");

        final matchData = snapshot.data()!;
        final match = MatchModel.fromMap(matchId, matchData);

        final playerIndex = match.players.indexOf(playerId);
        if (playerIndex != match.activePlayerIndex) {
          throw Exception("Not your turn");
        }

        if (match.gameStatus != 'playing') {
          throw Exception("Game is not active");
        }

        final toX = actionData['to']['x'] as int;
        final toY = actionData['to']['y'] as int;
        final type = actionData['type'] as String;

        final targetIndex = toY * gridCols + toX;

        const gridKey = 'grid';
        final currentGrid = match.grid;
        var newGrid = List<int>.from(currentGrid);

        final expectedSize = gridRows * gridCols;
        if (newGrid.length < expectedSize) {
          newGrid.addAll(List.filled(expectedSize - newGrid.length, 0));
        }

        var newPositions = List<Map<String, dynamic>>.from(
            match.playerPositions.map((p) => {'x': p.x, 'y': p.y})
        );

        String? winnerId = match.winnerId;
        String newGameStatus = match.gameStatus;

        if (type == 'shoot') {
          if (targetIndex >= 0 && targetIndex < newGrid.length && newGrid[targetIndex] > 0) {
            newGrid[targetIndex]--;
          }
        } else if (type == 'move') {
          newPositions[playerIndex] = {'x': toX, 'y': toY};

          if (toY == 0) {
            winnerId = playerId;
            newGameStatus = 'finished';
          }
        }

        final nextPlayerIndex = (match.activePlayerIndex + 1) % match.players.length;

        transaction.update(matchRef, {
          gridKey: newGrid,
          'playerPositions': newPositions,
          'activePlayerIndex': nextPlayerIndex,
          'lastMove': actionData,
          'gameStatus': newGameStatus,
          'winnerId': winnerId,
        });
      });
      return true;
    } catch (e) {
      debugPrint("Transaction failed: $e");
      return false;
    }
  }
}
