import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class HealthScoreScreen extends StatefulWidget {
  const HealthScoreScreen({super.key});

  @override
  HealthScoreScreenState createState() => HealthScoreScreenState();
}

class HealthScoreScreenState extends State<HealthScoreScreen> {
  double weight = 70.0;
  double height = 1.75;
  int heartRate = 75;
  int sleepHours = 7;
  int steps = 8000;
  bool isLoading = true;
  bool isSaving = false;
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _setupUserListener();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  void _setupUserListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _userSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && mounted) {
        final data = snapshot.data()!;
        setState(() {
          weight = double.tryParse(data['weight']?.toString() ?? '70') ?? 70;
          height = (double.tryParse(data['height']?.toString() ?? '175') ?? 175) / 100;
          heartRate = int.tryParse(data['heartRate']?.toString() ?? '75') ?? 75;
          sleepHours = int.tryParse(data['sleepHours']?.toString() ?? '7') ?? 7;
          steps = int.tryParse(data['steps']?.toString() ?? '8000') ?? 8000;
          isLoading = false;
        });
      }
    });
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          weight = double.tryParse(data['weight']?.toString() ?? '70') ?? 70;
          height = (double.tryParse(data['height']?.toString() ?? '175') ?? 175 / 100);
              heartRate = int.tryParse(data['heartRate']?.toString() ?? '75') ?? 75;
          sleepHours = int.tryParse(data['sleepHours']?.toString() ?? '7') ?? 7;
          steps = int.tryParse(data['steps']?.toString() ?? '8000') ?? 8000;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error loading health data")),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => isSaving = true);

    try {
      final healthScore = _calculateHealthScore();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'weight': weight,
        'height': (height * 100).round(),
        'heartRate': heartRate,
        'sleepHours': sleepHours,
        'steps': steps,
        'healthScore': healthScore, // Ensure healthScore is updated
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Health data saved successfully!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save health data")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  double _calculateBMI() => weight / (height * height);

  int _calculateHealthScore() {
    int score = 100;
    double bmi = _calculateBMI();

    if (bmi < 18.5 || bmi > 24.9) score -= 10;
    if (heartRate < 60 || heartRate > 100) score -= 15;
    if (sleepHours < 6) score -= 15;
    else if (sleepHours > 9) score -= 5;
    if (steps < 5000) score -= 20;
    else if (steps < 10000) score -= 10;

    return max(score, 0);
  }

  @override
  Widget build(BuildContext context) {
    int healthScore = _calculateHealthScore();
    Color scoreColor = healthScore > 75
        ? Colors.green
        : (healthScore > 50 ? Colors.orange : Colors.red);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Health Score Analysis"),
        actions: [
          IconButton(
            icon: isSaving
                ? const CircularProgressIndicator()
                : const Icon(Icons.save),
            onPressed: isSaving ? null : _saveChanges,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Health Score Display
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scoreColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    "Your Health Score",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: healthScore / 100,
                          strokeWidth: 10,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            "$healthScore",
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            healthScore > 75
                                ? "Excellent!"
                                : (healthScore > 50 ? "Good" : "Needs Work"),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Health Metrics
            const Text(
              "Health Metrics",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildEditableStat(
              "Weight",
              "${weight.toStringAsFixed(1)} kg",
                  (value) => setState(() => weight = double.tryParse(value) ?? weight),
            ),
            _buildEditableStat(
              "Height",
              "${(height * 100).toStringAsFixed(0)} cm",
                  (value) {
                final cm = double.tryParse(value) ?? height * 100;
                setState(() => height = cm / 100);
              },
            ),
            _buildEditableStat(
              "Heart Rate",
              "$heartRate bpm",
                  (value) => setState(() => heartRate = int.tryParse(value) ?? heartRate),
              isIdeal: heartRate >= 60 && heartRate <= 100,
            ),
            _buildEditableStat(
              "Sleep Hours",
              "$sleepHours hrs",
                  (value) => setState(() => sleepHours = int.tryParse(value) ?? sleepHours),
              isIdeal: sleepHours >= 7 && sleepHours <= 9,
            ),
            _buildEditableStat(
              "Daily Steps",
              "$steps steps",
                  (value) => setState(() => steps = int.tryParse(value) ?? steps),
              isIdeal: steps >= 10000,
            ),
            const SizedBox(height: 20),

            // BMI Calculation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calculate, color: Colors.blue),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "BMI Calculation",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${_calculateBMI().toStringAsFixed(1)} (${_getBmiCategory(_calculateBMI())})",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Health Tips
            const Text(
              "Health Tips",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildTipCard(healthScore),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableStat(
      String label,
      String value,
      Function(String) onChanged, {
        bool isIdeal = true,
      }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              isIdeal ? Icons.check_circle : Icons.warning,
              color: isIdeal ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    initialValue: value.split(" ")[0],
                    keyboardType: TextInputType.number,
                    onChanged: onChanged,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
            Text(value.split(" ")[1]),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(int score) {
    String tip;
    String title;
    Color color;

    if (score > 75) {
      title = "Great Job!";
      tip = "Maintain your healthy habits:\n"
          "• Continue balanced diet\n"
          "• Stay active daily\n"
          "• Get regular checkups";
      color = Colors.green;
    } else if (score > 50) {
      title = "Good Progress";
      tip = "Areas for improvement:\n"
          "• Aim for 7-8 hours sleep\n"
          "• Increase daily steps to 10,000\n"
          "• Manage stress levels";
      color = Colors.orange;
    } else {
      title = "Needs Improvement";
      tip = "Consider these actions:\n"
          "• Consult a healthcare provider\n"
          "• Create an exercise plan\n"
          "• Improve sleep routine";
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tip,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  String _getBmiCategory(double bmi) {
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25) return "Normal";
    if (bmi < 30) return "Overweight";
    return "Obese";
  }
}