import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import './home_screen.dart';
import 'package:paradox_2k26/main.dart';
import 'package:paradox_2k26/screens copy/level_complete_screen.dart';
import 'auth_choice_screen.dart';
import 'package:flutter/gestures.dart';

class Level2QuestionScreen extends StatefulWidget {
  final int level;
  final VoidCallback onLevelComplete;

  const Level2QuestionScreen({
    super.key,
    required this.level,
    required this.onLevelComplete,
  });

  @override
  State<Level2QuestionScreen> createState() => _Level2QuestionScreenState();
}

class _Level2QuestionScreenState extends State<Level2QuestionScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _answerController = TextEditingController();
  Map<String, dynamic>? _currentQuestion;
  int _score = 0;
  int _questionNumber = 1;
  bool _isLevelFinished = false; // Track if the level is finished

  final storage = const FlutterSecureStorage();
  AnimationController? _animationController;
  Animation<double>? _animation;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchCurrentQuestion();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentQuestion() async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://paradox-2k26.onrender.com/api/v1/question/current'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['success'] == true) {
          if (data['data'] == "Level is finished") {
            setState(() {
              _isLevelFinished = true;
            });
            // Optionally navigate to HurrayScreen immediately if no questions left
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HurrayScreen(completedLevel: 2),
              ),
            );
          } else if (data['data'] != null &&
              data['data']['ques'] != null &&
              data['data']['ques'].isNotEmpty) {
            setState(() {
              _currentQuestion = data['data']['ques'][0];
              _score = data['data']['score'] ?? 0;
              _questionNumber = data['data']['ques'][0]['id'] ?? 1;
              _isLevelFinished = false;
            });
          } else {
            _showErrorDialog('No question found for the current level.');
          }
        } else {
          _showErrorDialog(data['message'] ?? 'Error fetching question.');
        }
      } else {
        _showErrorDialog('Error fetching question: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Network error. Please try again.');
    }
  }

  Future<void> _checkAnswer() async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      return;
    }

    try {
      final response = await http.patch(
        Uri.parse('https://paradox-2k26.onrender.com/api/v1/question/next'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'answer': _answerController.text.trim()}),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 202) {
        if (data['success'] == true) {
          if (data['data'] == "Level is finished") {
            setState(() {
              _isLevelFinished = true;
            });
            widget
                .onLevelComplete(); // Inform HomeScreen about Level 2 completion
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HurrayScreen(completedLevel: 2),
              ), // Use Level 2 complete screen
            );
          } else if (data['data'] != null && data['data']['newQues'] != null) {
            setState(() {
              _score = data['data']['score'] ?? _score;
              _currentQuestion = data['data']['newQues'];
              _questionNumber = data['data']['newQues']['id'] ?? 1;
              _answerController.clear();
              _isLevelFinished = false;
            });
          } else {
            _showErrorDialog(data['message'] ?? 'Something went wrong.');
          }
        } else {
          _showErrorDialog(
            data['message'] ?? 'Incorrect answer! Please Try Again.',
          );
        }
      } else {
        _showErrorDialog('Incorrect Answer! Please Try Again');
      }
    } catch (e) {
      _showErrorDialog('Network error. Please try again.');
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

  Widget _buildQuestionContent(BuildContext context) {
    final String? description = _currentQuestion?['descriptionOrImgUrl'];
    if (description == null || _isLevelFinished) {
      return const Center(
          child: Text('Level Finished!', style: TextStyle(color: Colors.white)));
    }

    final RegExp urlRegex = RegExp(r'(https?://[\S]+)');
    final List<TextSpan> textSpans = [];

    // Improved parsing logic to avoid index issues
    description.splitMapJoin(
      urlRegex,
      onMatch: (Match match) {
        final String url = match.group(0)!;
        textSpans.add(
          TextSpan(
            text: url,
            style: const TextStyle(
              color: Colors.cyanAccent,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                }
              },
          ),
        );
        return url;
      },
      onNonMatch: (String text) {
        textSpans.add(TextSpan(
          text: text,
          style: const TextStyle(color: Colors.white, height: 1.5),
        ));
        return text;
      },
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: textSpans,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontFamily: 'PixelFont', // Match your game theme
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final double scaleFactor = width / 390;

    return Scaffold(
      extendBodyBehindAppBar: true, // Seamless background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'LEVEL ${widget.level}',
          style: const TextStyle(
            fontFamily: 'PixelFont',
            letterSpacing: 2,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/img.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: _isLevelFinished
              ? _buildFinishedState()
              : SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: width * 0.06),
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Score Badge
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
                    ),
                    child: Text(
                      'SCORE: $_score',
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontFamily: 'PixelFont',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Question Title Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    _currentQuestion?['title'] ?? 'SCANNING...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20 * scaleFactor,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'PixelFont',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Question Content (Glassmorphism)
                Container(
                  constraints: BoxConstraints(minHeight: height * 0.2, maxHeight: height * 0.4),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _buildQuestionContent(context),
                  ),
                ),
                const SizedBox(height: 30),
                // Answer Input
                TextField(
                  controller: _answerController,
                  focusNode: _focusNode,
                  style: const TextStyle(color: Colors.white, fontFamily: 'PixelFont'),
                  decoration: InputDecoration(
                    hintText: 'ENTER KEYCODE...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.4),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.cyanAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _checkAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 10,
                      shadowColor: Colors.cyanAccent.withOpacity(0.5),
                    ),
                    child: const Text(
                      'SUBMIT',
                      style: TextStyle(
                        fontFamily: 'PixelFont',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinishedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(color: Colors.cyanAccent),
          SizedBox(height: 20),
          Text(
            "LEVEL COMPLETE\nSYNCING DATA...",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontFamily: 'PixelFont', fontSize: 18),
          ),
        ],
      ),
    );
  }
}
