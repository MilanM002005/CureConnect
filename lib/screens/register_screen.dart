import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String _diabetes = "No";
  String _bloodRisk = "No";
  bool _isLoading = false;

  void _register() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    setState(() => _isLoading = true);

    String? error = await authService.signUpWithEmail(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _heightController.text.trim(),
      _weightController.text.trim(),
      _diabetes,
      _bloodRisk,
    );
    if (!mounted) return;

    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Text
            const Text(
              "Create Account",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 5),
            const Text(
              "Sign up to get started with CureConnect",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Name Input
            _buildTextField(_nameController, "Full Name", Icons.person),

            // Email Input
            _buildTextField(_emailController, "Email", Icons.email, keyboardType: TextInputType.emailAddress),

            // Password Input
            _buildTextField(_passwordController, "Password", Icons.lock, obscureText: true),

            // Height Input
            _buildTextField(_heightController, "Height (cm)", Icons.height, keyboardType: TextInputType.number),

            // Weight Input
            _buildTextField(_weightController, "Weight (kg)", Icons.monitor_weight, keyboardType: TextInputType.number),

            // Diabetes Dropdown
            _buildDropdown("Diabetic?", ["No", "Type 1", "Type 2"], (value) => setState(() => _diabetes = value)),

            // Blood-borne Risks Dropdown
            _buildDropdown("Blood-borne Risks?", ["No", "Yes"], (value) => setState(() => _bloodRisk = value)),

            const SizedBox(height: 20),

            // Register Button
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Sign Up", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),

            const SizedBox(height: 15),

            // Already have an account? Log In
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account?", style: TextStyle(color: Colors.black87)),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                  },
                  child: const Text("Log In", style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String hint,
      IconData icon, {
        bool obscureText = false,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.pinkAccent),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDropdown(String title, List<String> options, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          hintText: title,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
        value: options.first,
        items: options.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
        onChanged: (value) => onChanged(value!),
      ),
    );
  }
}
