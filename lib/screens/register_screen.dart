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
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String _gender = "Male";
  String _diabetes = "No";
  bool _isLoading = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _gender = "Male";
    _diabetes = "No";
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords don't match!")),
      );
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    setState(() => _isLoading = true);

    String? error = await authService.signUpWithEmail(
      _nameController.text.trim(),
      _mobileController.text.trim(),
      _dobController.text.trim(),
      _passwordController.text.trim(),
      _gender,
      _diabetes,
      "", // Add the missing 7th argument here
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFf8e1e4), Color(0xFFfce4ec)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with logo
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.medical_services,
                        size: 40,
                        color: Color(0xFFe91e63),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Create Your Account",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFe91e63),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Join CureConnect today",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Full Name
              _buildTextField(_nameController, "Full Name", Icons.person_outline),

              // Mobile Number
              _buildTextField(
                _mobileController,
                "Mobile Number",
                Icons.phone_android,
                keyboardType: TextInputType.phone,
              ),

              // Date of Birth
              TextField(
                controller: _dobController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: "Date of Birth",
                  prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFFe91e63)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 8),

              // Gender Dropdown
              _buildDropdown(
                "Gender",
                ["Male", "Female"],
                _gender,
                    (value) => setState(() => _gender = value ?? "Male"),
              ),

              // Password
              _buildTextField(
                _passwordController,
                "Password",
                Icons.lock_outline,
                obscureText: true,
              ),

              // Confirm Password
              _buildTextField(
                _confirmPasswordController,
                "Confirm Password",
                Icons.lock_outline,
                obscureText: true,
              ),

              // Diabetes Dropdown
              _buildDropdown(
                "Do you have diabetes?",
                ["No", "Yes"],
                _diabetes,
                    (value) => setState(() => _diabetes = value ?? "No"),
              ),

              const SizedBox(height: 25),

              // Register Button
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFe91e63),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Already have an account?
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(color: Colors.grey[700]),
                      children: const [
                        TextSpan(
                          text: "Sign in!",
                          style: TextStyle(
                            color: Color(0xFFe91e63),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFFe91e63)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDropdown(
      String title,
      List<String> options,
      String currentValue,
      Function(String?) onChanged,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: currentValue,
        decoration: InputDecoration(
          hintText: title,
          prefixIcon: const Icon(Icons.arrow_drop_down, color: Color(0xFFe91e63)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}