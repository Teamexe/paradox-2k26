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


  // ---------------------------------------------------------------------------
  // 2. THEME DATA (The "Instruction Manual" for Flutter)
  // ---------------------------------------------------------------------------
  // This function returns a 'ThemeData' object.
  // When you pass this to 'MaterialApp' in main.dart, Flutter reads this
  // manual to know how to style EVERY widget in your app automatically.
  // ---------------------------------------------------------------------------
  static ThemeData get darkGamingTheme {
    return ThemeData(
      // Enables the latest Material Design 3 features
      useMaterial3: true,

      // Tells Flutter "We are in Dark Mode", so it should default to white text
      brightness: Brightness.dark,

      // Sets the background color of every Scaffold (page) in the app
      scaffoldBackgroundColor: bgDark,

      // -----------------------------------------------------------------------
      // COLOR SCHEME
      // This is the new standard way to define colors. Widgets look here first.
      // -----------------------------------------------------------------------
      colorScheme: const ColorScheme.dark(
        primary: accentCyan,   // Used for buttons, active states, etc.
        surface: cardBlue,     // Used for Cards, BottomSheets, Dialogs
        onSurface: textWhite,  // The color of text ON TOP of the surface
      ),


      // card theme
      cardTheme: CardThemeData(
        color: cardBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0, // Removes the shadow for a "flat" modern look
      ),

     //appbar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent, // Makes it see-through
        elevation: 0, // Removes the shadow drop
        centerTitle: false, // Aligns title to the left (Android style)
        titleTextStyle: TextStyle(
          color: textWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}