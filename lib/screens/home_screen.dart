import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import 'health_score_screen.dart';
import 'profile_screen.dart';
import 'chatbot_screen.dart';
import 'categories_screen.dart';
import 'nearby_hospitals_screen.dart';
import 'emergency_screen.dart';
import 'petitions_screen.dart';
import 'checkups_screen.dart';
import 'recommendation_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _userInitial = 'A';
  int _healthScore = 78;
  String _healthStatus = 'Good Health Status';
  StreamSubscription<DocumentSnapshot>? _healthSubscription;

  final List<Widget> _screens = [
    const _HomeContent(),
    const RecommendationsScreen(),
    const PetitionsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _setupHealthScoreListener();
  }

  @override
  void dispose() {
    _healthSubscription?.cancel();
    super.dispose();
  }

  void _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.displayName != null && user.displayName!.isNotEmpty) {
      setState(() {
        _userInitial = user.displayName!.substring(0, 1).toUpperCase();
      });
    }
  }

  void _setupHealthScoreListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _healthSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && mounted) {
        final data = snapshot.data()!;
        setState(() {
          _healthScore = data['healthScore'] ?? 78;
          _healthStatus = _getHealthStatus(_healthScore);
        });
      }
    });
  }

  String _getHealthStatus(int score) {
    if (score >= 90) return 'Excellent Health';
    if (score >= 75) return 'Good Health';
    if (score >= 50) return 'Fair Health';
    return 'Needs Improvement';
  }

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

class _HomeContent extends StatelessWidget {
  const _HomeContent({Key? key}) : super(key: key);

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

    final Uri ambulanceUrl = Uri.parse("tel:102");
    if (await canLaunchUrl(ambulanceUrl)) {
      await launchUrl(ambulanceUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final bgColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Welcome to CureConnect",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      );
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.pink.shade400,
                            Colors.pink.shade600,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.withOpacity(0.3),
                            blurRadius: 6,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          homeState?._userInitial ?? 'A',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
              const SizedBox(height: 15),
              _buildHealthScoreCard(
                context,
                isDarkMode,
                homeState?._healthScore ?? 78,
                homeState?._healthStatus ?? 'Good Health Status',
              ),
              const SizedBox(height: 15),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  padding: const EdgeInsets.only(bottom: 20),
                  children: [
                    _buildGridItem(context, "Nearby Hospitals", Icons.local_hospital, Colors.red, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NearbyHospitalsScreen(selectedHospital: {},)),
                      );
                    }),
                    _buildGridItem(context, "Checkups", Icons.medical_services, Colors.blue, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CheckupsScreen()),
                      );
                    }),
                    _buildGridItem(context, "Emergency", Icons.warning, Colors.orange, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EmergencyScreen()),
                      );
                    }),
                    _buildGridItem(context, "Categories", Icons.category, Colors.green, () {
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'emergency',
            backgroundColor: Colors.red,
            onPressed: _callEmergency,
            child: const Icon(Icons.sos, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'chatbot',
            backgroundColor: Colors.pinkAccent,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatbotScreen()),
              );
            },
            child: const Icon(Icons.chat, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthScoreCard(BuildContext context, bool isDarkMode, int score, String status) {
    Color scoreColor = score > 75
        ? Colors.green
        : (score > 50 ? Colors.orange : Colors.red);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HealthScoreScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [scoreColor.withOpacity(0.3), scoreColor.withOpacity(0.5)]
                : [scoreColor.withOpacity(0.1), scoreColor.withOpacity(0.2)],
          ),
          boxShadow: [
            BoxShadow(
              color: scoreColor.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 6,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  ),
                ),
                Text(
                  "$score",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Health Score",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: score / 100,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                    minHeight: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, String title, IconData icon, Color iconColor, VoidCallback onTap) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.pink.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[700] : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(icon, size: 36, color: iconColor),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}