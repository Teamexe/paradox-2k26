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
  bool _isHintVisible = true;
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
      backgroundColor: const Color(0xFF0A0A12),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),

          child: Text(
            'LEVEL ${widget.level}',
            style: const TextStyle(
              color: Colors.deepPurpleAccent,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 3,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Glow

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Score & Stats Header
                  _buildStatRow(),
                  const SizedBox(height: 24),

                  // Question Card


                  // Image Container
                  _buildImageFrame(),
                  const SizedBox(height: 24),

                  // Hint Section
                  if (_isHintVisible) _buildHintBox(),

                  // Answer Input
                  _buildAnswerInput(),
                  const SizedBox(height: 32),

                  // Submit Button
                  _buildSubmitButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _statBadge(Icons.emoji_events_outlined, 'Score', '$_score', Colors.pink),
        GestureDetector(
          onTap: _isHintVisible ? () => setState(() => _isHintVisible = false) : _fetchHint,
          child: _statBadge(
              Icons.lightbulb_outline,
              'Hint',
              _isHintVisible ? 'Hide' : '-10 PTS',
              const Color(0xFFBC13FE)
          ),
        ),
      ],
    );
  }

  Widget _statBadge(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardBlue.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
              Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),

    );
  }

  Widget _buildImageFrame() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: _currentQuestion?['descriptionOrImgUrl'] != null
            ? Image.network(
          _currentQuestion!['descriptionOrImgUrl'],
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loading) {
            if (loading == null) return child;
            return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Colors.purple)));
          },
          errorBuilder: (c, e, s) => const SizedBox(
              height: 100,
              child: Center(child: Text('Data Decryption Failed (No Image)', style: TextStyle(color: Colors.white24)))
          ),
        )
            : const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Colors.purple))),
      ),
    );
  }

  Widget _buildHintBox() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFBC13FE).withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFBC13FE).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFD183FF), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _currentQuestion?['hint'] ?? 'Hint loading...',
              style: const TextStyle(color: Color(0xFFD183FF), fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text('YOUR ANSWER', style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 1)),
        ),
        TextField(
          controller: _answerController,
          focusNode: _focusNode,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          cursorColor: Colors.purpleAccent,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.cardBlue,
            hintText: 'Enter findings...',
            hintStyle: const TextStyle(color: Colors.white24),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.white10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.deepPurple, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _checkAnswer,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: AppTheme.bgDark,
          elevation: 10,
          shadowColor: AppTheme.accentCyan.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: _isSubmitting
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.bgDark))
            : const Text('SUBMIT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16)),
      ),
    );
  }

// Logic Methods (_fetchCurrentQuestion, _checkAnswer, etc.) go here...
}

