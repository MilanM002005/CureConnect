import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart'; // Make sure you have this import

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      // Show confirmation dialog
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (shouldLogout == true) {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        // Perform logout
        await FirebaseAuth.instance.signOut();

        // Navigate to login screen
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Failed to logout. Please try again."),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context); // Dismiss loading dialog
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).iconTheme.color,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null) ...[
              _buildUserInfo(user),
              const SizedBox(height: 20),
            ],

            _buildSectionTitle("ACCOUNT"),
            _buildSettingItem(
              icon: Icons.person_outline,
              title: "Edit Profile",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
            _buildSettingItem(
              icon: Icons.email_outlined,
              title: "Change Email",
              onTap: () => _showComingSoon(context),
            ),
            _buildSettingItem(
              icon: Icons.lock_outline,
              title: "Change Password",
              onTap: () => _showComingSoon(context),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle("APPEARANCE"),
            _buildToggleItem(
              icon: Icons.dark_mode,
              title: "Dark Mode",
              value: themeProvider.isDarkMode,
              onChanged: (value) => themeProvider.toggleTheme(value),
            ),
            _buildSettingItem(
              icon: Icons.text_fields,
              title: "Text Size",
              trailing: const Text("Medium", style: TextStyle(color: Colors.grey)),
              onTap: () => _showComingSoon(context),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle("PRIVACY & SECURITY"),
            _buildSettingItem(
              icon: Icons.lock_outline,
              title: "Privacy Settings",
              onTap: () => _showComingSoon(context),
            ),
            _buildSettingItem(
              icon: Icons.security_outlined,
              title: "Security",
              onTap: () => _showComingSoon(context),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle("SUPPORT"),
            _buildSettingItem(
              icon: Icons.help_outline,
              title: "Help Center",
              onTap: () => _showComingSoon(context),
            ),
            _buildSettingItem(
              icon: Icons.feedback_outlined,
              title: "Send Feedback",
              onTap: () => _showComingSoon(context),
            ),
            _buildSettingItem(
              icon: Icons.info_outline,
              title: "About",
              onTap: () => _showComingSoon(context),
            ),
            const SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed: () => _logout(context),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text("Logout", style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Center(
              child: Wrap(
                spacing: 20,
                runSpacing: 10,
                children: [
                  TextButton(
                    onPressed: () => _showComingSoon(context),
                    child: const Text("Terms of Service",
                        style: TextStyle(color: Colors.pinkAccent)),
                  ),
                  TextButton(
                    onPressed: () => _showComingSoon(context),
                    child: const Text("Privacy Policy",
                        style: TextStyle(color: Colors.pinkAccent)),
                  ),
                  TextButton(
                    onPressed: () => _showComingSoon(context),
                    child: const Text("App Version 1.0.0",
                        style: TextStyle(color: Colors.grey)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(User user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.pink.shade100,
        child: Text(
          user.displayName?.substring(0, 1).toUpperCase() ?? "U",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        user.displayName ?? "User",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(user.email ?? ""),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    IconData? trailingIcon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.pinkAccent, size: 24),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: trailing ??
            (trailingIcon != null
                ? Icon(trailingIcon, color: Colors.orange, size: 20)
                : const Icon(Icons.chevron_right, color: Colors.grey)),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.pinkAccent, size: 24),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.pinkAccent,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("This feature is coming soon!"),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}