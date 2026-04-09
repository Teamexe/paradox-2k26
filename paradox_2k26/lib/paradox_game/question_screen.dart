import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:paradox_2k26/paradox_game/auth_choice_screen.dart';
import 'package:paradox_2k26/paradox_game/level_complete_screen.dart';
import 'package:paradox_2k26/main.dart';
import 'package:paradox_2k26/theme/app_theme.dart';

class QuestionScreen extends StatefulWidget {
  final int level;
  final VoidCallback onLevelComplete;

  const QuestionScreen({
    super.key,
    required this.level,
    required this.onLevelComplete,
  });

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _answerController = TextEditingController();
  Map<String, dynamic>? _currentQuestion;
  bool _isHintVisible = false;
  bool _isHintUsed = false;
  int _score = 0;
  int _questionNumber = 1;
  bool _isSubmitting = false;

  final storage = const FlutterSecureStorage();
  AnimationController? _animationController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _checkLevelCompletion();
    _fetchCurrentQuestion();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  Future<void> _checkLevelCompletion() async {
    final isLevel1Completed = await storage.read(key: 'level1Completed');
    if (widget.level == 1 && isLevel1Completed == 'true') {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HurrayScreen(completedLevel: 1),
          ),
        );
      }
    }
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
        Uri.parse('https://paradox-2k26.onrender.com/api/v1/question/current'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['success'] == true &&
            data['data'] != null &&
            data['data']['ques'] != null &&
            data['data']['ques'].isNotEmpty) {
          setState(() {
            _currentQuestion = data['data']['ques'][0];
            _score = data['data']['score'] ?? 0;
            _questionNumber = data['data']['ques'][0]['id'] ?? 1;
            _isHintVisible = false;
            _isHintUsed = false;
          });
        } else {
          _showErrorDialog('No question found for the current level.');
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
            if (widget.level == 1) {
              await storage.write(key: 'level1Completed', value: 'true');
              widget.onLevelComplete();
            }
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HurrayScreen(completedLevel: 1),
                ),
              );
            }
          } else if (data['data'] != null && data['data']['newQues'] != null) {
            setState(() {
              _score = data['data']['score'] ?? _score;
              _currentQuestion = data['data']['newQues'];
              _questionNumber = data['data']['newQues']['id'] ?? 1;
              _answerController.clear();
              _isHintVisible = false;
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

  Future<void> _fetchHint() async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://paradox-2k26.onrender.com/api/v1/question/hint'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true &&
            data['data'] != null &&
            data['data']['hint'] != null) {
          setState(() {
            _isHintVisible = true;
            _isHintUsed = true;
            if (_currentQuestion != null) {
              _currentQuestion!['hint'] = data['data']['hint'];
            }
          });
        } else {
          _showErrorDialog(data['message'] ?? 'Error fetching hint.');
        }
      } else {
        _showErrorDialog('Error fetching hint');
      }
    } catch (e) {
      _showErrorDialog('Network error. Please try again.');
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

            // Question image
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              decoration: BoxDecoration(
                color: AppTheme.cardBlue,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _currentQuestion?['descriptionOrImgUrl'] != null
                    ? Image.network(
                        _currentQuestion!['descriptionOrImgUrl'],
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const SizedBox(
                            height: 200,
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: AppTheme.accentCyan),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(
                          height: 200,
                          child: Center(
                            child: Text('Image not available',
                                style: TextStyle(color: Colors.white38)),
                          ),
                        ),
                      )
                    : const SizedBox(
                        height: 200,
                        child: Center(
                          child: Text('Loading Image...',
                              style: TextStyle(color: Colors.white38)),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Hint display
            if (_isHintVisible && _currentQuestion?['hint'] != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFBC13FE).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFFBC13FE).withOpacity(0.3)),
                ),
                child: Text(
                  'Hint: ${_currentQuestion!['hint']}',
                  style:
                      const TextStyle(color: Color(0xFFD183FF), fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),

            // Hint + Score row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    if (!_isHintVisible) {
                      _fetchHint();
                    } else {
                      setState(() => _isHintVisible = false);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBlue,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline,
                            color: Color(0xFFFFD700), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          _isHintVisible ? 'Hide Hint' : 'Hint (-10)',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
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
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
