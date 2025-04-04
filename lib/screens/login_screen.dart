import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  // Using ValueNotifier to resolve the warning about unused field
  final ValueNotifier<bool> _isPasswordVisible = ValueNotifier(false);

  Future<void> _login() async {
    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      String? error = await authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = error;
        });

        if (error == null) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Login failed. Please try again.";
        });
      }
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      String? error = await authService.signInWithGoogle();

      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = error;
        });

        if (error == null) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Google Sign-In failed. Please try again.";
        });
      }
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailController.text.isEmpty) {
      setState(() => _errorMessage = "Enter your email to reset password.");
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      String? error = await authService.resetPassword(_emailController.text.trim());

      if (mounted) {
        if (error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Password reset email sent!")),
          );
        } else {
          setState(() => _errorMessage = error);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = "Failed to send password reset email.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Access Account",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text("Access your personalized healthcare options"),
            const SizedBox(height: 20),
            _buildTextField(Icons.email, "Your email address", controller: _emailController),
            const SizedBox(height: 10),
            _buildPasswordField(),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _forgotPassword,
                child: const Text("Forgot your password?", style: TextStyle(color: Colors.pink)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Log In", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Colors.grey),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                final authService = Provider.of<AuthService>(context, listen: false);
                String? error = await authService.signInWithGoogle();

                if (error == null) {
                  Navigator.pushReplacementNamed(context, '/home');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error)),
                  );
                }
              },
              icon: Image.asset(
                "assets/google_logo.png",
                height: 24,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.red),
              ),
              label: const Text("Sign in with Google", style: TextStyle(color: Colors.black)),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildTextField(IconData icon, String hint, {bool isPassword = false, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildPasswordField() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isPasswordVisible,
      builder: (context, isVisible, child) {
        return TextField(
          controller: _passwordController,
          obscureText: !isVisible,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock, color: Colors.grey),
            hintText: "Enter your password",
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            suffixIcon: IconButton(
              icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
              onPressed: () => _isPasswordVisible.value = !_isPasswordVisible.value,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _isPasswordVisible.dispose();
    super.dispose();
  }
}
