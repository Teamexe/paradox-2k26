import 'package:flutter/material.dart';
import 'package:paradox/commit_clash_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paradox',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D1117)),
        useMaterial3: true,
      ),
      home: const CommitClashApp(), 
    );
  }
}
