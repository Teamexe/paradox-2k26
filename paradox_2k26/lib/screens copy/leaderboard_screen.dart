import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'loader.dart';

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
  late Client _httpClient;

  @override
  void initState() {
    super.initState();
    _httpClient = Client();
    _connectToSSE();
  }

  @override
  void dispose() {
    _httpClient.close();
    super.dispose();
  }

  Future<void> _connectToSSE() async {
    final leaderboardProvider = Provider.of<LeaderboardProvider>(
      context,
      listen: false,
    );

    leaderboardProvider.setLoading(true);

    try {
      final request = Request(
        'GET',
        Uri.parse(
          'https://paradox-2025.vercel.app/api/v1/rank/leaderboard-stream',
        ),
      );

      final response = _httpClient.send(request);

      response.asStream().listen((http.StreamedResponse r) {
        r.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen(
              (String line) {
                if (line.startsWith('data: ')) {
                  final data = line.substring(6);
                  try {
                    final leaderboard = jsonDecode(data) as List<dynamic>;
                    final List<Map<String, dynamic>> leaderboardData =
                        leaderboard.cast<Map<String, dynamic>>();

                    leaderboardProvider.updateLeaderboard(leaderboardData);
                  } catch (e) {
                    print('Error decoding SSE data: $e');
                  }
                }
              },
              onError: (e) {
                print('SSE Error: $e');
                _showErrorDialog('Error connecting to leaderboard stream');
              },
              onDone: () {
                print('SSE connection closed');
              },
              cancelOnError: true,
            );
      });
    } catch (e) {
      print('Error connecting to SSE: $e');
      _showErrorDialog('Error connecting to leaderboard stream');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    double scale(double value) => value * (width / 390);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 600;
          return Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            decoration: const BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                image: AssetImage('assets/images/all_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Consumer<LeaderboardProvider>(
              builder: (context, leaderboardProvider, child) {
                if (leaderboardProvider.isLoading) {
                  return const Center(child: LoaderScreen());
                }

                final leaderboardData = leaderboardProvider.leaderboardData;

                leaderboardData.sort(
                  (a, b) => (b['score'] ?? 0).compareTo(a['score'] ?? 0),
                );

                final topPlayers =
                    leaderboardData.length >= 3
                        ? leaderboardData.sublist(0, 3)
                        : leaderboardData;

                return Column(
                  children: [
                    SizedBox(height: constraints.maxHeight * 0.08),
                    SizedBox(
                      height: constraints.maxHeight * 0.07,
                      child: Image.asset('assets/images/paradox_text.png'),
                    ),
                    SizedBox(height: constraints.maxHeight * 0.02),
                    Container(
                      width: constraints.maxWidth * 0.9,
                      height: constraints.maxHeight * 0.4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(scale(30)),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/leaderboard_bg.png'),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Image.asset(
                                  'assets/images/exe_logo1.png',
                                  height: constraints.maxHeight * 0.045,
                                ),
                                Text(
                                  'Leaderboard',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: scale(16),
                                    fontFamily: 'PixelFont',
                                  ),
                                ),
                                Image.asset(
                                  'assets/images/Nimbus_white_logo.png',
                                  height: constraints.maxHeight * 0.046,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: constraints.maxHeight * 0.19,
                            child: Image.asset(
                              'assets/images/leaderboard_podium.png',
                              width: constraints.maxWidth * 0.7,
                            ),
                          ),
                          // Podium Avatars
                          if (topPlayers.isNotEmpty)
                            _buildPodiumAvatar(
                              top: constraints.maxHeight * 0.04,
                              name: topPlayers[0]['name'],
                              score: topPlayers[0]['score'],
                              avatarPath: 'assets/images/avatar_1.png',
                              scale: scale,
                            ),
                          if (topPlayers.length >= 2)
                            _buildPodiumAvatar(
                              top: constraints.maxHeight * 0.07,
                              left: constraints.maxWidth * 0.09,
                              name: topPlayers[1]['name'],
                              score: topPlayers[1]['score'],
                              avatarPath: 'assets/images/avatar_2.png',
                              scale: scale,
                            ),
                          if (topPlayers.length >= 3)
                            _buildPodiumAvatar(
                              top: constraints.maxHeight * 0.1,
                              right: constraints.maxWidth * 0.12,
                              name: topPlayers[2]['name'],
                              score: topPlayers[2]['score'],
                              avatarPath: 'assets/images/avatar_3.png',
                              scale: scale,
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: constraints.maxHeight * 0.02),
                    // Leaderboard List
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth * 0.05,
                        ),
                        itemCount: leaderboardData.length,
                        itemBuilder: (context, index) {
                          final data = leaderboardData[index];
                          return _buildLeaderboardItem(
                            rank: index + 1,
                            name: data['name'],
                            score: data['score'],
                            size: size,
                            scale: scale,
                            profileImagePath: data['profileImagePath'],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPodiumAvatar({
    required double top,
    double? left,
    double? right,
    required String name,
    required int? score,
    required String avatarPath,
    required double Function(double) scale,
  }) {
    final truncatedName =
        name.length > 12 ? '${name.substring(0, 12)}...' : name;

    return Positioned(
      top: top,
      left: left,
      right: right,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: scale(67),
                height: scale(67),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: scale(3)),
                ),
                child: ClipOval(
                  child: Image.asset(avatarPath, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Image.asset(
                  'assets/images/india_flag.png',
                  width: scale(20),
                  height: scale(20),
                ),
              ),
            ],
          ),
          SizedBox(height: scale(5)),
          Text(
            truncatedName,
            style: TextStyle(
              color: Colors.white,
              fontSize: scale(14),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: scale(5)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: scale(8),
              vertical: scale(3),
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(scale(8)),
            ),
            child: Text(
              'Score: ${score ?? 0}',
              style: TextStyle(
                color: Colors.white,
                fontSize: scale(10),
                fontWeight: FontWeight.bold,
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
    required int? score,
    required Size size,
    required double Function(double) scale,
    String? profileImagePath,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: scale(12), vertical: scale(10)),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(scale(15)),
      ),
      child: Row(
        children: [
          Container(
            width: scale(38),
            height: scale(38),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(scale(10)),
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: scale(18),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: scale(15)),
          Container(
            width: scale(38),
            height: scale(38),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.red, width: 2),
            ),
            child: ClipOval(
              child:
                  profileImagePath != null
                      ? Image.asset(profileImagePath, fit: BoxFit.cover)
                      : Image.asset(
                        'assets/images/user_image.webp',
                        fit: BoxFit.cover,
                      ),
            ),
          ),
          SizedBox(width: scale(15)),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: scale(15),
                vertical: scale(8),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(scale(15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: scale(16),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'KdamThmorPro',
                    ),
                  ),
                  Text(
                    '${score ?? 0}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: scale(16),
                      fontFamily: 'KdamThmorPro',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
