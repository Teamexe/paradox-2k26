import 'package:flutter/material.dart';

// i created a class here to put the app theme design here
class AppTheme {

  // colors used in our theme


  // main bg color (Dark Navy)
  static const Color bgDark = Color(0xFF0B162C);

  //  color for cards, lists, and other (Lighter Navy)
  static const Color cardBlue = Color(0xFF152238);

  // color for buttons and active icons (Electric Cyan)
  static const Color accentCyan = Color(0xFF00C6FF);

  // Standard text colors (White)
  static const Color textWhite = Colors.white;
  static const Color textGrey = Colors.white54;


  static ThemeData get darkGamingTheme {
    return ThemeData(

      useMaterial3: true,

      brightness: Brightness.dark,

      scaffoldBackgroundColor: bgDark,

      colorScheme: const ColorScheme.dark(
        primary: accentCyan,
        surface: cardBlue,
        onSurface: textWhite,
      ),


      // card theme
      cardTheme: CardThemeData(
        color: cardBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),

      //appbar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}