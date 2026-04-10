import 'package:flutter/material.dart';
import 'package:paradox_2k26/theme/app_theme.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  static const List<String> _rules = [
    'Eligibility: The game is open to all.',
    'Participation: The game must be played solo throughout all levels.',
    'Levels: The game consists of two levels — Level 1 includes 40 image-based word guessing questions, while Level 2 contains 10 text-based riddles or puzzles.',
    'Scoring: Each correct answer will increase the score by 50 points.',
    'Use of Hint: Using hint will decrease the score by 10 points.',
    'Qualification: Only the top 50 scorers from Level 1 will be eligible to move on to Level 2..',
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
