import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import './home_screen.dart';
import 'package:paradox_25/main.dart';
import 'package:paradox_25/screens/level_complete_screen.dart';
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
        Uri.parse('https://paradox-2025.vercel.app/api/v1/question/current'),
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
      return const Center(child: Text('Level Finished!'));
    }

    // Regular expression to find URLs in the text
    final RegExp urlRegex = RegExp(r'(https?://[\S]+)');
    final List<TextSpan> textSpans = [];
    int currentIndex = 0;

    description.splitMapJoin(
      urlRegex,
      onMatch: (Match match) {
        final String url = match.group(0)!;
        textSpans.add(
          TextSpan(
            text: url,
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            recognizer:
                TapGestureRecognizer()
                  ..onTap = () async {
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url));
                    } else {
                      _showErrorDialog('Could not launch $url');
                    }
                  },
          ),
        );
        currentIndex = match.end;
        return url; // Must return the matched string
      },
      onNonMatch: (String text) {
        if (currentIndex >= 0 && currentIndex < text.length) {
          textSpans.add(
            TextSpan(
              text: text.substring(currentIndex),
              style: const TextStyle(color: Colors.black),
            ),
          );
          currentIndex = text.length;
        } else {
          // Handle the case where currentIndex is out of bounds
          print(
            'Warning: currentIndex out of bounds in onNonMatch: $currentIndex, text length: ${text.length}',
          );
          currentIndex = text.length; // Prevent further out-of-bounds issues
        }
        return text; // Must return the non-matched string
      },
    );

    // Add the remaining text if no URL was found or after the last URL
    if (currentIndex >= 0 && currentIndex < description.length) {
      textSpans.add(
        TextSpan(
          text: description.substring(currentIndex),
          style: const TextStyle(color: Colors.black),
        ),
      );
    } else if (description.isNotEmpty) {
      print(
        'Warning: currentIndex out of bounds for remaining text: $currentIndex, description length: ${description.length}',
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: textSpans,
          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.045),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final double padding = width * 0.05;
    final double normalFont = width * 0.045;
    final double scaleFactor = width / 390;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Level ${widget.level} Question',
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
      body: Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/all_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child:
            _isLevelFinished
                ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Level Finished!",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      CircularProgressIndicator(), // Or any other indicator
                      Text(
                        "Navigating to next screen...",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                )
                : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
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
                                borderRadius: BorderRadius.circular(
                                  15 * scaleFactor,
                                ),
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
                                borderRadius: BorderRadius.circular(
                                  15 * scaleFactor,
                                ),
                                color: Colors.grey.shade200,
                              ),
                              child: _buildQuestionContent(context),
                            ),
                            SizedBox(height: height * 0.025),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(), // Placeholder for removed hint
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 15 * scaleFactor,
                                    vertical: 8 * scaleFactor,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade800,
                                    borderRadius: BorderRadius.circular(
                                      10 * scaleFactor,
                                    ),
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
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15 * scaleFactor,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade800,
                                  borderRadius: BorderRadius.circular(
                                    10 * scaleFactor,
                                  ),
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
                                      MaterialStateProperty.resolveWith<Color>((
                                        Set<MaterialState> states,
                                      ) {
                                        if (states.contains(
                                          MaterialState.pressed,
                                        )) {
                                          return Colors.grey;
                                        }
                                        return Colors.white;
                                      }),
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                        Colors.black,
                                      ),
                                  shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder
                                  >(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        10 * scaleFactor,
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
                  ],
                ),
      ),
    );
  }
}
