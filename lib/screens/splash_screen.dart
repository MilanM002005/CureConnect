import 'package:cureconnect_app/screens/register_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink, // Background color remains the same
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top spacing for aesthetics
          const SizedBox(height: 50),

          // Logo and app title
          Column(
            children: [
              Image.asset(
                'assets/logo.png', // Replace with your logo asset
                height: 150,
                semanticLabel: 'App Logo', // Accessibility improvement
              ),
              const SizedBox(height: 20),
              const Text(
                "CURECONNECT",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Find Your Best Healthcare",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          // "Get Started" Button (Replaces automatic navigation)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                child: const Text(
                  "Get Started",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pink),
                ),
              ),
            ),
          ),

          // Bottom spacing for aesthetics
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
