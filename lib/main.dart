import 'package:flutter/material.dart';
import 'screens/homescreen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'Paradox 2K26',

      // customised theme  taken from the app_theme.dart
      theme: AppTheme.darkGamingTheme,
      home: const HomeScreen(),
    );
  }
}