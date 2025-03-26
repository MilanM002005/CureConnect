import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String? _diabetesStatus;
  String? _bloodBorneRisk;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userData = await authService.getUserDetails();

    if (!mounted) return;

    setState(() {
      _userData = userData;
      _heightController.text = userData?['height'] ?? '';
      _weightController.text = userData?['weight'] ?? '';
      _diabetesStatus = userData?['diabetes'] ?? 'No';
      _bloodBorneRisk = userData?['bloodRisk'] ?? 'No';
      _isLoading = false;
    });
  }

  Future<void> updateUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'height': _heightController.text,
        'weight': _weightController.text,
        'diabetes': _diabetesStatus,
        'bloodRisk': _bloodBorneRisk,
      });

      if (!mounted) return;

      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update profile.")),
      );
    }
  }

  void _openHealthID() async {
    final Uri url = Uri.parse("https://www.pristyncare.com/create-abha-health-id/");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open Health ID page.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Profile",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildProfileCard(),
            const SizedBox(height: 20),
            _isEditing ? _buildEditForm() : _buildUserInfo(),
            const SizedBox(height: 20),

            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                icon: const Icon(Icons.health_and_safety, color: Colors.white),
                label: const Text("View Health ID", style: TextStyle(fontSize: 16, color: Colors.white)),
                onPressed: _openHealthID,
              ),
            ),

            const SizedBox(height: 15),

            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                onPressed: () async {
                  await Provider.of<AuthService>(context, listen: false).signOut();
                  if (!mounted) return;
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text("Log Out", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300, blurRadius: 5, spreadRadius: 1),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userData?["name"] ?? "User Name",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _userData?["email"] ?? "user@example.com",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "User Information",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.pink.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        _buildInfoRow("Height", _userData?['height'] ?? "N/A"),
        _buildInfoRow("Weight", _userData?['weight'] ?? "N/A"),
        _buildInfoRow("Diabetes", _userData?['diabetes'] ?? "N/A"),
        _buildInfoRow("Blood Borne Risk", _userData?['bloodRisk'] ?? "N/A"),
        const SizedBox(height: 15),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
          onPressed: () {
            setState(() {
              _isEditing = true;
            });
          },
          child: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        TextField(controller: _heightController, decoration: const InputDecoration(labelText: "Height (cm)")),
        const SizedBox(height: 10),
        TextField(controller: _weightController, decoration: const InputDecoration(labelText: "Weight (kg)")),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _diabetesStatus,
          decoration: const InputDecoration(labelText: "Diabetes"),
          items: ["Yes", "No"].map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (newValue) => setState(() => _diabetesStatus = newValue),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _bloodBorneRisk,
          decoration: const InputDecoration(labelText: "Blood Borne Risk"),
          items: ["Yes", "No"].map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (newValue) => setState(() => _bloodBorneRisk = newValue),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontSize: 16, color: Colors.grey)),
      ]),
    );
  }
}
