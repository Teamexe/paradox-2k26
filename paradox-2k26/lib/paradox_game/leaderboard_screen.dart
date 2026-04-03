import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:paradox/paradox_game/loader.dart';
import 'package:paradox/theme/app_theme.dart';

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
            'https://paradox-2025.vercel.app/api/v1/rank/leaderboard-stream'),
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
      backgroundColor: AppTheme.bgDark,
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
                Text(
                  'LEADERBOARD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    fontFamily: 'monospace',
                    shadows: [
                      Shadow(
                        color: AppTheme.accentCyan.withOpacity(0.4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
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
    final truncatedName =
        name.length > 10 ? '${name.substring(0, 10)}...' : name;
    return Expanded(
      child: Column(
        children: [
          // Avatar circle
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
              color: AppTheme.cardBlue,
            ),
            child: Center(
              child: Icon(Icons.person, color: color, size: 24),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            truncatedName,
            style: const TextStyle(
                color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Podium bar
          Container(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '#$rank',
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$score pts',
                  style: TextStyle(
                    color: color.withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
              ],
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
    final isTop3 = rank <= 3;
    final rankColor = rank == 1
        ? AppTheme.accentCyan
        : rank == 2
            ? const Color(0xFFBC13FE)
            : rank == 3
                ? const Color(0xFF39FF14)
                : Colors.white38;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBlue,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isTop3 ? rankColor.withOpacity(0.2) : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  color: rankColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '$score',
            style: TextStyle(
              color: AppTheme.accentCyan.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
