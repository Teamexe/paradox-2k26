import 'package:flutter/material.dart';

class PrizesScreen extends StatelessWidget {
  const PrizesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;

          // Responsive scaling function
          double scale(double value) =>
              value * (screenWidth / 390); // Base width

          // Responsive font size function
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
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.03),
                    // Logo
                    SizedBox(
                      height: scale(60),
                      child: Image.asset(
                        'assets/images/paradox_text.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    // Main card
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(scale(30)),
                      ),
                      child: Stack(
                        children: [
                          // Background
                          Container(
                            width: double.infinity,
                            constraints: BoxConstraints(
                              minHeight: screenHeight * 0.6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(scale(30)),
                              image: const DecorationImage(
                                image: AssetImage(
                                  'assets/images/leaderboard_list_bg.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          // Foreground
                          Padding(
                            padding: EdgeInsets.all(screenWidth * 0.04),
                            child: Column(
                              children: [
                                SizedBox(height: screenHeight * 0.02),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/exe_logo1.png',
                                      height: scale(32),
                                      width: scale(32),
                                      fit: BoxFit.contain,
                                    ),
                                    SizedBox(width: screenWidth * 0.02),
                                    Text(
                                      'Top Prizes',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: responsiveFont(21),
                                        fontFamily: 'PixelFont',
                                      ),
                                    ),
                                    SizedBox(width: screenWidth * 0.02),
                                    Image.asset(
                                      'assets/images/Nimbus_white_logo.png',
                                      height: scale(32),
                                      width: scale(32),
                                      fit: BoxFit.contain,
                                    ),
                                  ],
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                // Prize card
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.04,
                                    horizontal: screenWidth * 0.04,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      scale(30),
                                    ),
                                    image: const DecorationImage(
                                      image: AssetImage(
                                        'assets/images/prizes_bg.png',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Wrap(
                                        alignment: WrapAlignment.center,
                                        spacing: screenWidth * 0.04,
                                        runSpacing: screenHeight * 0.02,
                                        children: [
                                          _buildPrize(
                                            'assets/images/cash_prize.png',
                                            '1500 INR',
                                            scale,
                                            screenWidth,
                                            screenHeight,
                                          ),
                                          _buildPrize(
                                            'assets/images/speaker.png',
                                            '1000 INR',
                                            scale,
                                            screenWidth,
                                            screenHeight,
                                          ),
                                          _buildPrize(
                                            'assets/images/watch.png',
                                            '500 INR',
                                            scale,
                                            screenWidth,
                                            screenHeight,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.02),
                                    ],
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.04),

                                // ⭐ Updated prize announcement box ⭐
                                SizedBox(
                                  width: double.infinity,
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.03,
                                    ),
                                    height: scale(40),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(
                                        scale(20),
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.04,
                                    ),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/Rectangle 82.png',
                                          height: scale(20),
                                          width: scale(20),
                                          fit: BoxFit.contain,
                                        ),
                                        SizedBox(width: screenWidth * 0.025),
                                        Expanded(
                                          child: Text(
                                            'The prize will be announced soon',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: responsiveFont(16),
                                              fontFamily: 'Overlock',
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(height: screenHeight * 0.03),
                              ],
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
        },
      ),
    );
  }

  Widget _buildPrize(
    String imagePath,
    String prizeName,
    double Function(double) scale,
    double screenWidth,
    double screenHeight,
  ) {
    return Column(
      children: [
        SizedBox(
          height: scale(100),
          width: scale(110),
          child: Image.asset(imagePath, fit: BoxFit.contain),
        ),
        SizedBox(height: screenHeight * 0.01),
        Text(
          prizeName,
          style: TextStyle(
            color: Colors.white,
            fontSize: scale(16),
            fontWeight: FontWeight.bold,
            fontFamily: 'Overlock',
          ),
        ),
      ],
    );
  }
}
