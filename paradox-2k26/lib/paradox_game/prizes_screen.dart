import 'package:flutter/material.dart';
import 'package:paradox/theme/app_theme.dart';

class PrizesScreen extends StatelessWidget {
  const PrizesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // Title
              Text(
                'PRIZES',
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
              const SizedBox(height: 30),

              // Prize cards
              _buildPrizeCard(
                rank: '1st',
                prize: '₹1500',
                icon: Icons.emoji_events_rounded,
                color: const Color(0xFFFFD700),
                description: 'First Place Winner',
              ),
              const SizedBox(height: 16),
              _buildPrizeCard(
                rank: '2nd',
                prize: '₹1000',
                icon: Icons.emoji_events_rounded,
                color: AppTheme.accentCyan,
                description: 'Second Place Winner',
              ),
              const SizedBox(height: 16),
              _buildPrizeCard(
                rank: '3rd',
                prize: '₹500',
                icon: Icons.emoji_events_rounded,
                color: const Color(0xFFBC13FE),
                description: 'Third Place Winner',
              ),

              const SizedBox(height: 30),

              // Announcement card
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.cardBlue,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.accentCyan.withOpacity(0.15)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.campaign_rounded,
                      color: AppTheme.accentCyan.withOpacity(0.6),
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'More prizes will be announced soon!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrizeCard({
    required String rank,
    required String prize,
    required IconData icon,
    required Color color,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$rank Place',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            prize,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
