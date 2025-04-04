import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final TextEditingController _nameController = TextEditingController();
  String? _diabetesStatus = 'No';
  String? _bloodBorneRisk = 'No';
  String? _gender = 'Prefer not to say';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final userData = await authService.getUserDetails();

    if (!mounted) return;
    setState(() {
      _nameController.text = userData?['name'] ?? '';
      _heightController.text = userData?['height']?.toString() ?? '';
      _weightController.text = userData?['weight']?.toString() ?? '';
      _diabetesStatus = userData?['diabetes'] ?? 'No';
      _bloodBorneRisk = userData?['bloodRisk'] ?? 'No';
      _gender = userData?['gender'] ?? 'Prefer not to say';
      _isLoading = false;
    });
  }

  Future<void> _updateUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': _nameController.text,
        'height': _heightController.text,
        'weight': _weightController.text,
        'diabetes': _diabetesStatus,
        'bloodRisk': _bloodBorneRisk,
        'gender': _gender,
      });

      if (!mounted) return;
      setState(() {
        _isEditing = false;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Profile updated successfully!"),
          backgroundColor: Colors.pink[300],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Failed to update profile."),
          backgroundColor: Colors.pink[300],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'My Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.pink[400]!,
                      Colors.pink[300]!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            actions: [
              if (!_isEditing)
                IconButton(
                  icon: const Icon(Icons.edit, size: 26),
                  onPressed: () => setState(() => _isEditing = true),
                ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            sliver: SliverToBoxAdapter(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Avatar and Name
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.pink[100],
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.pink[600],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _nameController.text.isEmpty
                            ? 'Your Name'
                            : _nameController.text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        FirebaseAuth.instance.currentUser?.email ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.pink[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Info Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _isEditing
                          ? _buildEditForm()
                          : _buildUserInfo(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        _buildInfoRow(
          icon: Icons.height,
          label: 'Height',
          value: _heightController.text.isEmpty
              ? 'Not set'
              : '${_heightController.text} cm',
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(height: 1, color: Colors.pinkAccent),
        ),
        _buildInfoRow(
          icon: Icons.monitor_weight,
          label: 'Weight',
          value: _weightController.text.isEmpty
              ? 'Not set'
              : '${_weightController.text} kg',
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(height: 1, color: Colors.pinkAccent),
        ),
        _buildInfoRow(
          icon: Icons.bloodtype,
          label: 'Diabetes',
          value: _diabetesStatus ?? 'Not set',
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(height: 1, color: Colors.pinkAccent),
        ),
        _buildInfoRow(
          icon: Icons.health_and_safety,
          label: 'Blood Risk',
          value: _bloodBorneRisk ?? 'Not set',
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(height: 1, color: Colors.pinkAccent),
        ),
        _buildInfoRow(
          icon: Icons.person_outline,
          label: 'Gender',
          value: _gender ?? 'Not set',
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: _getInputDecoration(
            label: 'Full Name',
            icon: Icons.person,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _heightController,
          keyboardType: TextInputType.number,
          decoration: _getInputDecoration(
            label: 'Height (cm)',
            icon: Icons.height,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _weightController,
          keyboardType: TextInputType.number,
          decoration: _getInputDecoration(
            label: 'Weight (kg)',
            icon: Icons.monitor_weight,
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _diabetesStatus,
          items: ['Select', 'Yes', 'No'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) => setState(() => _diabetesStatus = value),
          decoration: _getInputDecoration(
            label: 'Diabetes Status',
            icon: Icons.bloodtype,
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _bloodBorneRisk,
          items: ['No', 'Yes'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) => setState(() => _bloodBorneRisk = value),
          decoration: _getInputDecoration(
            label: 'Blood Risk',
            icon: Icons.health_and_safety,
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _gender,
          items: ['Male', 'Female', 'Other', 'Prefer not to say'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) => setState(() => _gender = value),
          decoration: _getInputDecoration(
            label: 'Gender',
            icon: Icons.person_outline,
          ),
        ),
      ],
    );
  }

  InputDecoration _getInputDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.pink[700]),
      prefixIcon: Icon(icon, color: Colors.pink[500]),
      filled: true,
      fillColor: Colors.pink[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.pink[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.pink[400]!),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isEditing) ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.pink[400]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => setState(() => _isEditing = false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.pink[700],
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink[400],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _updateUserData,
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => launchUrl(Uri.parse('https://www.pristyncare.com/create-abha-health-id/')),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.health_and_safety),
              SizedBox(width: 8),
              Text('Health ID'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: BorderSide(color: Colors.pink[400]!),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () async {
            await Provider.of<AuthService>(context, listen: false).signOut();
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, '/login');
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, color: Colors.pink[600]),
              const SizedBox(width: 8),
              Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.pink[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.pink[500], size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}