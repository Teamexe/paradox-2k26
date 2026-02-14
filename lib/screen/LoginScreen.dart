import 'package:flutter/material.dart';
import 'homescreen.dart';
import 'SignupScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller to capture user input
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Access our AppTheme colors
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // We use a SafeArea so content doesn't get hidden behind the notch
      body: SafeArea(
        child: Center(
          // SingleChildScrollView prevents "Pixel Overflow" errors when keyboard pops up
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch, // Stretches buttons to full width
              children: [

                const Text(
                  "PARADOX",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Welcome back",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                ),

                const SizedBox(height: 50),

                // --- 2. EMAIL INPUT (Only this is needed) ---
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: colorScheme.surface, // Dark Navy from our theme
                    hintText: "Email Address  (College Id)",
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    prefixIcon: Icon(Icons.email_outlined, color: colorScheme.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none, // Removes the default line
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // --- 3. LOGIN BUTTON ---
                SizedBox(
                  height: 55, // Makes the button taller and easier to tap
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to Home and REMOVE back button (so they can't go back to login)
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary, // Cyan color
                      foregroundColor: Colors.black, // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "LOGIN",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // --- 4. SIGNUP LINK ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ", style: TextStyle(color: Colors.grey)),
                    GestureDetector(
                      onTap: () {
                        // Navigate to Sign Up screen for the existing users to sign up
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupScreen()),
                        );
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}