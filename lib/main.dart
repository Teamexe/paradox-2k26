import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:provider/provider.dart';
import 'package:paradox_2k26/screens/splash_screen.dart';
import 'package:paradox_2k26/paradox_game/home_screen.dart';
import 'package:paradox_2k26/paradox_game/leaderboard_screen.dart';
import 'package:paradox_2k26/paradox_game/rules_screen.dart';
import 'package:paradox_2k26/paradox_game/prizes_screen.dart';
import 'package:paradox_2k26/paradox_game/profile_screen.dart';
import 'package:paradox_2k26/widgets/bottom_navigation.dart';
import 'package:paradox_2k26/theme/app_theme.dart';
import 'package:paradox_2k26/screens/online_game_screen.dart';
import 'package:paradox_2k26/screens copy/level2_question_screen.dart';
import 'package:paradox_2k26/screens copy/loader.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LeaderboardProvider(),
      child: const MyApp(),
    ),
  );
=======
import 'package:paradox/screen/splash_screen.dart';
import 'package:paradox/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
>>>>>>> main
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
<<<<<<< HEAD
      title: 'Paradox',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkGamingTheme,
    home: PrizesScreen(),
    );
  }
}

/// MainScreen — The tab-based home with bottom navigation
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    LeaderboardScreen(),
    RulesScreen(),
    PrizesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
=======
      title: 'Pre-Paradox',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkGamingTheme,
      home: const SplashScreen(),
>>>>>>> main
    );
  }
}
