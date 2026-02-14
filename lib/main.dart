import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:paradox/screen/LoginScreen.dart';
import 'package:paradox/screen/SignupScreen.dart';
import 'screen/HomeScreen.dart';
import 'theme/app_theme.dart';
=======
import 'package:paradox/minigames/lights_out_screen.dart';
import 'package:paradox/minigames/mine_scan_screen.dart';
import 'package:paradox/minigames/multi_task_screen.dart';
import 'package:paradox/minigames/node_decryption_screen.dart';
import 'package:paradox/minigames/pathfinder_screen.dart';
import 'package:paradox/commit_clash_app.dart';
>>>>>>> main

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
<<<<<<< HEAD

      debugShowCheckedModeBanner: false,
      title: 'Paradox 2K26',

      // customised theme  taken from the app_theme.dart
      theme: AppTheme.darkGamingTheme,
      home: const LoginScreen(),
    );
  }
}
=======
      title: 'Paradox',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: PathfinderScreen(),
    );
  }
}
>>>>>>> main
