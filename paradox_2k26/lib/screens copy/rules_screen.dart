import 'package:flutter/material.dart';

class RulesScreen extends StatefulWidget {
  const RulesScreen({super.key});

  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _rulesController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  final List<Map<String, String>> _rules = const [
    {
      'title': 'Eligibility',
      'desc': 'The game is open to all.',
    },
    {
      'title': 'Participation',
      'desc': 'The game must be played solo throughout all levels.',
    },
    {
      'title': 'Levels',
      'desc':
          'The game consists of two levels — Level 1 includes 40 image-based word guessing questions, while Level 2 contains 10 text-based riddles or puzzles.',
    },
    {
      'title': 'Scoring',
      'desc': 'Each correct answer will increase the score by 50 points.',
    },
    {
      'title': 'Use of Hint',
      'desc': 'Using a hint will decrease the score by 10 points.',
    },
    {
      'title': 'Qualification',
      'desc':
          'Only the top 50 scorers from Level 1 will be eligible to move on to Level 2.',
    },
  ];

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerFade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    ));

    _rulesController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + (_rules.length * 150)),
    );

    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _rulesController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _rulesController.dispose();
    super.dispose();
  }

  Animation<double> _ruleItemFade(int index) {
    final start = (index * 0.12).clamp(0.0, 0.7);
    final end = (start + 0.4).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _rulesController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

  Animation<Offset> _ruleItemSlide(int index) {
    final start = (index * 0.12).clamp(0.0, 0.7);
    final end = (start + 0.4).clamp(0.0, 1.0);
    return Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _rulesController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;

          double scale(double value) => value * (screenWidth / 390);
          double responsiveFont(double size) => size * (screenWidth / 375);

          return Container(
            width: screenWidth,
            height: screenHeight,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/all_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.02),

                  // ── Paradox Logo ──
                  FadeTransition(
                    opacity: _headerFade,
                    child: SlideTransition(
                      position: _headerSlide,
                      child: SizedBox(
                        height: scale(55),
                        child: Image.asset(
                          'assets/images/paradox_text.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.015),

                  // ── RULES Title Image ──
                  FadeTransition(
                    opacity: _headerFade,
                    child: SizedBox(
                      height: scale(45),
                      child: Image.asset('assets/images/RULES.png'),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // ── Main Card ──
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(scale(24)),
                        image: const DecorationImage(
                          image: AssetImage(
                            'assets/images/leaderboard_list_bg.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: screenHeight * 0.02),

                          // ── Header Row with logos ──
                          FadeTransition(
                            opacity: _headerFade,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/exe_logo1.png',
                                  height: scale(28),
                                  width: scale(28),
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Text(
                                  'Instructions',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: responsiveFont(20),
                                    fontFamily: 'PixelFont',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Image.asset(
                                  'assets/images/Nimbus_white_logo.png',
                                  height: scale(28),
                                  width: scale(28),
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.012),

                          // ── Glowing Divider ──
                          Container(
                            height: 1.5,
                            margin: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.08,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  const Color(0xFF00C6FF).withOpacity(0.6),
                                  const Color(0xFF00C6FF).withOpacity(0.8),
                                  const Color(0xFF00C6FF).withOpacity(0.6),
                                  Colors.transparent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF00C6FF).withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.015),

                          // ── Scrollable Rules List ──
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.04,
                              ),
                              child: Column(
                                children: [
                                  for (int i = 0; i < _rules.length; i++)
                                    SlideTransition(
                                      position: _ruleItemSlide(i),
                                      child: FadeTransition(
                                        opacity: _ruleItemFade(i),
                                        child: _buildRuleCard(
                                          index: i,
                                          title: _rules[i]['title']!,
                                          description: _rules[i]['desc']!,
                                          scale: scale,
                                          responsiveFont: responsiveFont,
                                          screenWidth: screenWidth,
                                          screenHeight: screenHeight,
                                        ),
                                      ),
                                    ),
                                  SizedBox(height: screenHeight * 0.02),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.01),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRuleCard({
    required int index,
    required String title,
    required String description,
    required double Function(double) scale,
    required double Function(double) responsiveFont,
    required double screenWidth,
    required double screenHeight,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(scale(16)),
        color: Colors.black.withOpacity(0.35),
        border: Border.all(
          color: const Color(0xFF00C6FF).withOpacity(0.12),
          width: 1,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // ── Cyan accent left bar ──
            Container(
              width: scale(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(scale(16)),
                  bottomLeft: Radius.circular(scale(16)),
                ),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF00C6FF),
                    Color(0xFF0072FF),
                  ],
                ),
              ),
            ),

            // ── Number Badge ──
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: scale(12),
                vertical: scale(14),
              ),
              child: Container(
                width: scale(34),
                height: scale(34),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF00C6FF),
                      Color(0xFF0072FF),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00C6FF).withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: responsiveFont(15),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Oswald',
                    ),
                  ),
                ),
              ),
            ),

            // ── Rule Text ──
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  top: scale(12),
                  bottom: scale(12),
                  right: scale(14),
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$title: ',
                        style: TextStyle(
                          color: const Color(0xFF00C6FF),
                          fontSize: responsiveFont(16),
                          fontFamily: 'Oswald',
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      ),
                      TextSpan(
                        text: description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.88),
                          fontSize: responsiveFont(14.5),
                          fontFamily: 'Overlock',
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
