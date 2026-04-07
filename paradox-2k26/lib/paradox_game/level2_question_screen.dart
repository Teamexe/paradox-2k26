import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:paradox_2k26/paradox_game/auth_choice_screen.dart';
import 'package:paradox_2k26/paradox_game/level_complete_screen.dart';
import 'package:paradox_2k26/main.dart';
import 'package:paradox_2k26/theme/app_theme.dart';
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
  bool _isLevelFinished = false;
  bool _isSubmitting = false;

  final storage = const FlutterSecureStorage();
  AnimationController? _animationController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchCurrentQuestion();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
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
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('https://paradox-2025.vercel.app/api/v1/question/current'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['success'] == true) {
          if (data['data'] == "Level is finished") {
            setState(() => _isLevelFinished = true);
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HurrayScreen(completedLevel: 2),
                ),
              );
            }
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
    if (_isSubmitting) return;
    final token = await storage.read(key: 'authToken');
    if (token == null) return;

    setState(() => _isSubmitting = true);

    try {
      final response = await http.patch(
        Uri.parse('https://paradox-2025.vercel.app/api/v1/question/next'),
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
            setState(() => _isLevelFinished = true);
            widget.onLevelComplete();
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HurrayScreen(completedLevel: 2),
                ),
              );
            }
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
              data['message'] ?? 'Incorrect answer! Please Try Again.');
        }
      } else {
        _showErrorDialog('Incorrect Answer! Please Try Again');
      }
    } catch (e) {
      _showErrorDialog('Network error. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBlue,
        title: const Text('Error', style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child:
                const Text('OK', style: TextStyle(color: AppTheme.accentCyan)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent() {
    final String? description = _currentQuestion?['descriptionOrImgUrl'];
    if (description == null || _isLevelFinished) {
      return const Center(
          child: Text('Level Finished!',
              style: TextStyle(color: Colors.white)));
    }

    final RegExp urlRegex = RegExp(r'(https?://[\S]+)');
    final List<TextSpan> textSpans = [];
    int lastEnd = 0;

    for (final match in urlRegex.allMatches(description)) {
      if (match.start > lastEnd) {
        textSpans.add(TextSpan(
          text: description.substring(lastEnd, match.start),
          style: const TextStyle(color: Colors.white70),
        ));
      }
      final url = match.group(0)!;
      textSpans.add(TextSpan(
        text: url,
        style: const TextStyle(
          color: AppTheme.accentCyan,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            if (await canLaunchUrl(Uri.parse(url))) {
              await launchUrl(Uri.parse(url));
            }
          },
      ));
      lastEnd = match.end;
    }

    if (lastEnd < description.length) {
      textSpans.add(TextSpan(
        text: description.substring(lastEnd),
        style: const TextStyle(color: Colors.white70),
      ));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(children: textSpans, style: const TextStyle(fontSize: 15)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: Text(
          'Level ${widget.level}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontFamily: 'monospace',
          ),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white54),
      ),
      body: _isLevelFinished
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Level Finished!",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(color: AppTheme.accentCyan),
                  const SizedBox(height: 10),
                  Text("Navigating to next screen...",
                      style: TextStyle(color: Colors.white.withOpacity(0.5))),
                ],
              ),
            )
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Question title
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBlue,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.accentCyan.withOpacity(0.15)),
                    ),
                    child: Text(
                      'Q: ${_currentQuestion?['title'] ?? 'Loading...'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Question content (text with links)
                  Container(
                    constraints: BoxConstraints(
                      maxHeight:
                          MediaQuery.of(context).size.height * 0.4,
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.cardBlue,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: _buildQuestionContent(),
                  ),
                  const SizedBox(height: 16),

                  // Score row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBlue,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppTheme.accentCyan.withOpacity(0.2)),
                        ),
                        child: Text(
                          'Score: $_score',
                          style: const TextStyle(
                            color: AppTheme.accentCyan,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Answer field
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardBlue,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.accentCyan.withOpacity(0.15)),
                    ),
                    child: TextField(
                      controller: _answerController,
                      focusNode: _focusNode,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Type your answer here...',
                        hintStyle: TextStyle(color: Colors.white24),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _checkAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentCyan,
                        foregroundColor: AppTheme.bgDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.bgDark,
                              ),
                            )
                          : const Text(
                              'SUBMIT',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}
