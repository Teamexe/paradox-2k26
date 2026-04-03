import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import './home_screen.dart';
import 'package:paradox_25/main.dart';
import 'package:paradox_25/screens/level_complete_screen.dart';
import 'auth_choice_screen.dart';

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

  final storage = const FlutterSecureStorage();
  AnimationController? _animationController;
  Animation<double>? _animation;
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

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
  }

  Future<void> _checkLevelCompletion() async {
    final isLevel1Completed = await storage.read(key: 'level1Completed');
    if (widget.level == 1 && isLevel1Completed == 'true') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HurrayScreen(completedLevel: 1),
        ),
      );
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
    if (token == null) {
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://paradox-2025.vercel.app/api/v1/question/current'),
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
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      return;
    }

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
            if (widget.level == 1) {
              await storage.write(key: 'level1Completed', value: 'true');
              widget
                  .onLevelComplete(); // Call the callback to update HomeScreen state
            }
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HurrayScreen(completedLevel: 1),
              ),
            );
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

  Future<void> _fetchHint() async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://paradox-2025.vercel.app/api/v1/question/hint'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true &&
            data['data'] != null &&
            data['data']['hint'] != null) {
          String hint = data['data']['hint'];

          setState(() {
            _isHintVisible = true;
            if (!_isHintUsed) {
              _isHintUsed = true;
            }
            if (_currentQuestion != null) {
              _currentQuestion!['hint'] = hint;
            }
          });
        } else {
          _showErrorDialog(data['message'] ?? 'Error fetching hint.');
        }
      } else {
        print('Error fetching hint: ${response.statusCode}');
        _showErrorDialog('Error fetching hint');
        return;
      }
    } catch (e) {
      print('Error: $e');
      _showErrorDialog('Network error. Please try again.');
      return;
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Level ${widget.level}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'PixelFont',
          ),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          final double height = constraints.maxHeight;

          double scale(double value) => value * (width / 390);

          final double padding = width * 0.05;
          final double smallFont = width * 0.035;
          final double normalFont = width * 0.045;

          return Container(
            width: width,
            height: height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/all_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: padding,
                  vertical: padding * 0.5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(padding * 0.75),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(scale(15)),
                      ),
                      child: Text(
                        'Q: ${_currentQuestion?['title'] ?? 'Loading...'}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: normalFont,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: height * 0.03),
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: height * 0.6,
                        maxWidth: width * 0.9,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(scale(15)),
                        color: Colors.grey.shade200,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(scale(15)),
                        child:
                            _currentQuestion?['descriptionOrImgUrl'] != null
                                ? Image.network(
                                  _currentQuestion!['descriptionOrImgUrl'],
                                  fit: BoxFit.contain,
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                  errorBuilder:
                                      (context, error, stackTrace) => Center(
                                        child: Text(
                                          'Image not available',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: smallFont,
                                          ),
                                        ),
                                      ),
                                )
                                : Center(
                                  child: Text(
                                    'Loading Image...',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: smallFont,
                                    ),
                                  ),
                                ),
                      ),
                    ),
                    SizedBox(height: height * 0.025),
                    if (_isHintVisible && _currentQuestion?['hint'] != null)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(padding * 0.5),
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade100,
                          borderRadius: BorderRadius.circular(scale(10)),
                        ),
                        child: Text(
                          'Hint: ${_currentQuestion!['hint']}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: normalFont,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (_isHintVisible && _currentQuestion?['hint'] != null)
                      SizedBox(height: height * 0.015),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (!_isHintVisible) {
                              _fetchHint();
                            } else {
                              setState(() {
                                _isHintVisible = false;
                              });
                            }
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: Colors.yellow,
                                size: scale(20),
                              ),
                              SizedBox(width: scale(5)),
                              Text(
                                _isHintVisible ? 'Hide Hint' : 'Hint',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: normalFont,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: scale(15),
                            vertical: scale(8),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(scale(10)),
                          ),
                          child: Text(
                            'Score: $_score',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: normalFont,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.025),
                    GestureDetector(
                      onTap: () {
                        FocusScope.of(context).requestFocus(_focusNode);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: scale(15)),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(scale(10)),
                        ),
                        child: TextField(
                          controller: _answerController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Type your answer here...',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                          ),
                          focusNode: _focusNode,
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.025),
                    SizedBox(
                      width: double.infinity,
                      height: height * 0.065,
                      child: ElevatedButton(
                        onPressed: _checkAnswer,
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.resolveWith<Color>((
                                Set<WidgetState> states,
                              ) {
                                if (states.contains(WidgetState.pressed)) {
                                  return Colors.grey;
                                }
                                return Colors.white;
                              }),
                          foregroundColor: WidgetStateProperty.all<Color>(
                            Colors.black,
                          ),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    scale(10),
                                  ),
                                ),
                              ),
                        ),
                        child: Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: normalFont,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
