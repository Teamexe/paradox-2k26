import 'package:flutter/material.dart';
import 'package:paradox/screen/splash_screen.dart';
import 'package:paradox/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paradox 2K26',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkGamingTheme,
      home: const SplashScreen(),
    );
  }
}
