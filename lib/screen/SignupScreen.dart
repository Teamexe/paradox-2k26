import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Controllers for the form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // --- 1. HEADER ---
              const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Join the Paradox 2K26 community.",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
              ),

              const SizedBox(height: 30),

              // --- 2. PERSONAL DETAILS ---
              _buildTextField(
                  label: "Full Name",
                  icon: Icons.person_outline,
                  controller: _nameController,
                  scheme: colorScheme
              ),
              const SizedBox(height: 16),

              _buildTextField(
                  label: "College Email ID",
                  icon: Icons.school_outlined, // Changed icon to match "College"
                  controller: _emailController,
                  scheme: colorScheme
              ),

              const SizedBox(height: 25),

              // --- 3. GENERATE OTP BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Trigger Node.js backend to send email
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("OTP Sent to your College Mail!")),
                    );
                  },
                  icon: const Icon(Icons.send_rounded, size: 20),
                  label: const Text("GENERATE OTP"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary, // Cyan text
                    side: BorderSide(color: colorScheme.primary), // Cyan border
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // --- 4. OTP INPUT (6 DIGITS) ---
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6, // 6 digits for secure OTP
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    letterSpacing: 12, // Spaced out look
                    fontWeight: FontWeight.bold
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  counterText: "",
                  filled: true,
                  fillColor: colorScheme.surface,
                  hintText: "000000",
                  hintStyle: TextStyle(color: Colors.grey.shade700, letterSpacing: 12),
                  prefixIcon: const Icon(Icons.lock_clock_outlined, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // --- 5. CREATE ACCOUNT BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Verify OTP with backend
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "VERIFY & REGISTER",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGET ---
  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required ColorScheme scheme,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: scheme.surface,
        hintText: label,
        hintStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: scheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}