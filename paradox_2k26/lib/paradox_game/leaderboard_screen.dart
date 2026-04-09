import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:paradox_2k26/paradox_game/loader.dart';
import 'package:paradox_2k26/theme/app_theme.dart';

class LeaderboardProvider with ChangeNotifier {
  List<Map<String, dynamic>> _leaderboardData = [];
  bool _isLoading = true;

  List<Map<String, dynamic>> get leaderboardData => _leaderboardData;
  bool get isLoading => _isLoading;

  void updateLeaderboard(List<Map<String, dynamic>> data) {
    _leaderboardData = data;
    _isLoading = false;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late http.Client _httpClient;

  @override
  void initState() {
    super.initState();
    _httpClient = http.Client();
    _connectToSSE();
  }

  @override
  void dispose() {
    _httpClient.close();
    super.dispose();
  }

  Future<void> _connectToSSE() async {
    final leaderboardProvider =
        Provider.of<LeaderboardProvider>(context, listen: false);
    leaderboardProvider.setLoading(true);

    try {
      final request = http.Request(
        'GET',
        Uri.parse(
            'https://paradox-2k26.onrender.com/api/v1/rank/leaderboard-stream'),
      );
      final response = _httpClient.send(request);

      response.asStream().listen((http.StreamedResponse r) {
        r.stream.transform(utf8.decoder).transform(const LineSplitter()).listen(
          (String line) {
            if (line.startsWith('data: ')) {
              final data = line.substring(6);
              try {
                final leaderboard = jsonDecode(data) as List<dynamic>;
                final List<Map<String, dynamic>> leaderboardData =
                    leaderboard.cast<Map<String, dynamic>>();
                leaderboardProvider.updateLeaderboard(leaderboardData);
              } catch (e) {
                debugPrint('Error decoding SSE data: $e');
              }
            }
          },
          onError: (e) {
            debugPrint('SSE Error: $e');
          },
          cancelOnError: true,
        );
      });
    } catch (e) {
      debugPrint('Error connecting to SSE: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        centerTitle: true, // Optional: Centers the text
        automaticallyImplyLeading: false, // Removes the back button if it exists
        elevation: 0, // Optional: Removes the shadow for a flat look
      ),
      backgroundColor: const Color(0xFF0A0A12),
      body: SafeArea(
        child: Consumer<LeaderboardProvider>(
          builder: (context, leaderboardProvider, child) {
            if (leaderboardProvider.isLoading) {
              return const Center(child: LoaderScreen());
            }

            final leaderboardData =
                List<Map<String, dynamic>>.from(leaderboardProvider.leaderboardData);
            leaderboardData
                .sort((a, b) => (b['score'] ?? 0).compareTo(a['score'] ?? 0));

            final topPlayers = leaderboardData.length >= 3
                ? leaderboardData.sublist(0, 3)
                : leaderboardData;

            return Column(
              children: [
                const SizedBox(height: 20),
                // Title

                const SizedBox(height: 24),

                // Top 3 podium
                if (topPlayers.isNotEmpty) _buildPodium(topPlayers),

                const SizedBox(height: 20),

                // Divider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(height: 1, color: Colors.white10),
                ),

                const SizedBox(height: 10),

                // Full list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: leaderboardData.length,
                    itemBuilder: (context, index) {
                      final data = leaderboardData[index];
                      return _buildLeaderboardItem(
                        rank: index + 1,
                        name: data['name'] ?? 'Unknown',
                        score: data['score'] ?? 0,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPodium(List<Map<String, dynamic>> topPlayers) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          if (topPlayers.length >= 2)
            _buildPodiumColumn(
              rank: 2,
              name: topPlayers[1]['name'] ?? 'Unknown',
              score: topPlayers[1]['score'] ?? 0,
              height: 80,
              color: const Color(0xFFBC13FE),
            ),
          const SizedBox(width: 8),
          // 1st place
          _buildPodiumColumn(
            rank: 1,
            name: topPlayers[0]['name'] ?? 'Unknown',
            score: topPlayers[0]['score'] ?? 0,
            height: 110,
            color: AppTheme.accentCyan,
          ),
          const SizedBox(width: 8),
          // 3rd place
          if (topPlayers.length >= 3)
            _buildPodiumColumn(
              rank: 3,
              name: topPlayers[2]['name'] ?? 'Unknown',
              score: topPlayers[2]['score'] ?? 0,
              height: 60,
              color: const Color(0xFF39FF14),
            ),
        ],
      ),
    );
  }

  Widget _buildPodiumColumn({
    required int rank,
    required String name,
    required int score,
    required double height,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Glow effect behind Rank
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: rank == 1 ? 70 : 55,
                height: rank == 1 ? 70 : 55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ],
                ),
              ),
              CircleAvatar(
                radius: rank == 1 ? 30 : 25,
                backgroundColor: AppTheme.cardBlue,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: rank == 1 ? 24 : 18),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "#$rank",
                    style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          // The Bar
          Container(
            width: double.infinity,
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [color.withOpacity(0.7), color.withOpacity(0.05)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border.all(color: color.withOpacity(0.5), width: 1.5),
            ),
            child: Center(
              child: Text(
                '$score',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildLeaderboardItem({
    required int rank,
    required String name,
    required int score,
  }) {
    // Determine if we show an emoji or a styled number
    Widget rankLeading;
    if (rank == 1) {
      rankLeading = const Text('🥇', style: TextStyle(fontSize: 22));
    } else if (rank == 2) {
      rankLeading = const Text('🥈', style: TextStyle(fontSize: 22));
    } else if (rank == 3) {
      rankLeading = const Text('🥉', style: TextStyle(fontSize: 22));
    } else {
      rankLeading = Text(
        rank.toString().padLeft(2, '0'),
        style: TextStyle(
          color: Colors.white.withOpacity(0.3),
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        // Subtle gradient for a "glass" look
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.01),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rank <= 3
              ? AppTheme.accentCyan.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 35, child: Center(child: rankLeading)),
          const SizedBox(width: 12),
          // Avatar with Initial
          CircleAvatar(
            radius: 16,
            backgroundColor: rank <= 3 ? AppTheme.accentCyan.withOpacity(0.1) : Colors.white10,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                color: rank <= 3 ? AppTheme.accentCyan : Colors.white60,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: rank <= 3 ? Colors.white : Colors.white.withOpacity(0.8),
                fontSize: 15,
                fontWeight: rank <= 3 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          // Score Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                score.toString(),
                style: TextStyle(
                  color: Colors.pink,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                'PTS',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.2),
                  fontSize: 9,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
