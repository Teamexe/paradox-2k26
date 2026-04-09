import 'package:flutter/material.dart';
import 'package:paradox_2k26/theme/app_theme.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  static const List<String> _rules = [
    'Eligibility: The game is open to all the Nit Hamirpur students.',
    'Participation: The game must be played solo throughout all levels.',
    'Levels: The game consists of two levels — Level 1 includes 40 image-based word guessing questions, while Level 2 contains 6 text-based riddles or puzzles.',
    'Scoring: Each correct answer will increase the score by 100 points if done without using Hint and if you use Hint you will get +90 for that particular question',
    'Qualification: Only the top 50 scorers from Level 1 will be eligible to move on to Level 2.',
    'You will be given unlimited tries to solve any particular question but you have to submit the correct answer of the current question to see the next questions of any particular level ',
    'There will be some images based questions in level 1 and you have to predict the answer from that images , it may be either in english or hindi language to guess from that image  ',
    'The winner(1st rank)  of the level 2  will be rewarded with 10,000 cash prize',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // Title
              Text(
                'RULES',
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
              const SizedBox(height: 8),
              Text(
                'Instructions',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),

              // Rules list
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBlue,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppTheme.accentCyan.withOpacity(0.1)),
                  ),
                  child: ListView.separated(
                    itemCount: _rules.length,
                    separatorBuilder: (_, __) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Container(
                          height: 1, color: Colors.white.withOpacity(0.05)),
                    ),
                    itemBuilder: (context, index) {
                      return _buildRuleItem(index + 1, _rules[index]);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRuleItem(int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppTheme.accentCyan.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              '$number',
              style: TextStyle(
                color: AppTheme.accentCyan.withOpacity(0.8),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
