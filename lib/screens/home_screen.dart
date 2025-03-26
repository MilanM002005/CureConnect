import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'recommendation_screen.dart';
import 'settings_screen.dart';
import '../main.dart';
import 'profile_screen.dart';
import 'chatbot_screen.dart';
import 'categories_screen.dart';
import 'nearby_hospitals_screen.dart';
import 'emergency_screen.dart';
import 'petitions_screen.dart';
import 'health_score_screen.dart';
import 'checkups_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const RecommendationsScreen(),
    const PetitionsScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Recommendations"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Petitions"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  Future<void> _callEmergency() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final contactsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('contacts')
        .orderBy('priority', descending: true)
        .get();

    if (contactsSnapshot.docs.isNotEmpty) {
      String contactNumber = contactsSnapshot.docs.first['phone'];
      final Uri url = Uri.parse("tel:$contactNumber");
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
        return;
      }
    }

    final Uri ambulanceUrl = Uri.parse("tel:102"); // 🚑 Ambulance Number
    if (await canLaunchUrl(ambulanceUrl)) {
      await launchUrl(ambulanceUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final bgColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Welcome to CureConnect",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      );
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.pink,
                      child: const Text("A", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              TextField(
                decoration: InputDecoration(
                  hintText: "Search",
                  hintStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
                  prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.white70 : Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                ),
              ),
              const SizedBox(height: 20),
              _buildHealthScoreCard(context, isDarkMode),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  children: [
                    _buildGridItem(context, "Nearby Hospitals", Icons.local_hospital, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NearbyHospitalsScreen()),
                      );
                    }),
                    _buildGridItem(context, "Checkups", Icons.medical_services, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CheckupsScreen()), // ✅ Checkups Restored
                      );
                    }),
                    _buildGridItem(context, "Emergency", Icons.warning, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EmergencyScreen()),
                      );
                    }),
                    _buildGridItem(context, "Categories", Icons.category, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Emergency Button
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.red,
            onPressed: _callEmergency,
            child: const Icon(Icons.sos, color: Colors.white), // 🆘 Emergency Call
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            backgroundColor: Colors.pinkAccent,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatbotScreen()), // ✅ Chatbot Restored
              );
            },
            child: const Icon(Icons.chat, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.pink.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.redAccent),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthScoreCard(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.pink.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Health Score",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black),
                ),
                const SizedBox(height: 5),
                Text(
                  "Based on your health tracking, your score is 78 and considered good.",
                  style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.white70 : Colors.black54),
                ),
                const SizedBox(height: 5),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HealthScoreScreen()),
                    );
                  },
                  child: Text(
                    "Tell me more >",
                    style: TextStyle(color: isDarkMode ? Colors.pinkAccent : Colors.pink.shade400, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
