import 'package:flutter/material.dart';
import 'package:sample1/screens/register_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink, 
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          
          const SizedBox(height: 50),

          
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(40), // Curved edges
                child: Image.asset(
                  'assets/logo.png', 
                  height: 150,
                  semanticLabel: 'App Logo', 
                ),
              ),
              const SizedBox(height: 20),
              const Text("       "),const Text("       "),
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

      
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
