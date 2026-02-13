import 'package:flutter/material.dart';
import 'package:paradox/minigames/lights_out_screen.dart';
import 'package:paradox/minigames/mine_scan_screen.dart';
import 'package:paradox/minigames/multi_task_screen.dart';
import 'package:paradox/minigames/node_decryption_screen.dart';
import 'package:paradox/minigames/pathfinder_screen.dart';
import 'package:paradox/commit_clash_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paradox',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: PathfinderScreen(),
    );
  }
}
