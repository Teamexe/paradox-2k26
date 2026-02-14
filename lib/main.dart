import 'package:flutter/material.dart';
import 'package:paradox/screen/LoginScreen.dart';
import 'package:paradox/screen/SignupScreen.dart';
import 'screen/HomeScreen.dart';
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
      home: const LoginScreen(),
    );
  }
}