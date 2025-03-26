import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'home_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("ACCOUNT"),
            _buildSettingItem(
              icon: Icons.person_outline,
              title: "Accounts Center",
              onTap: () {},
            ),
            const SizedBox(height: 20),

            _buildSectionTitle("APPEARANCE"),
            _buildToggleItem(
              icon: Icons.dark_mode,
              title: "Night mode",
              value: themeProvider.isDarkMode,
              onChanged: (value) => themeProvider.toggleTheme(value),
            ),
            _buildSettingItem(
              icon: Icons.text_fields,
              title: "Text size",
              trailing: const Text("Medium", style: TextStyle(color: Colors.grey)),
              onTap: () {},
            ),
            const SizedBox(height: 20),

            _buildSectionTitle("OTHER SETTINGS"),
            _buildSettingItem(
              icon: Icons.bookmark_border,
              title: "Saved",
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.lock_outline,
              title: "Privacy",
              trailingIcon: Icons.warning_amber_outlined,
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.payment,
              title: "Payment",
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.help_outline,
              title: "Help & Support",
              onTap: () {},
            ),
            const SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 80),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {},
                child: const Text("Logout", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),

            Center(
              child: Column(
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text("Terms of Service",
                        style: TextStyle(color: Colors.pinkAccent, fontSize: 14)),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text("Privacy Policy",
                        style: TextStyle(color: Colors.pinkAccent, fontSize: 14)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
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
    return ListTile(
      leading: Icon(icon, color: Colors.black, size: 24),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: trailing ??
          (trailingIcon != null
              ? Icon(trailingIcon, color: Colors.orange, size: 20)
              : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black, size: 24),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.pinkAccent,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
    );
  }
}
