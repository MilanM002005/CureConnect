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
  double weight = 70.0; // kg (default)
  double height = 1.75; // meters (default)
  int heartRate = 75; // bpm
  int sleepHours = 7; // hours
  int steps = 8000; // steps per day
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        weight = double.tryParse(data['weight']?.toString() ?? '70') ?? 70;
        height = (double.tryParse(data['height']?.toString() ?? '175') ?? 175) / 100; // Convert cm to meters
        isLoading = false;
      });
    }
  }

  double _calculateBMI() {
    return weight / (height * height);
  }

  int _calculateHealthScore() {
    int score = 100;

    double bmi = _calculateBMI();
    if (bmi < 18.5 || bmi > 24.9) {
      score -= 10;
    }

    if (heartRate < 60 || heartRate > 100) {
      score -= 15;
    }

    if (sleepHours < 6) {
      score -= 15;
    } else if (sleepHours > 9) {
      score -= 5;
    }

    if (steps < 5000) {
      score -= 20;
    } else if (steps < 10000) {
      score -= 10;
    }

    return max(score, 0);
  }

  @override
  Widget build(BuildContext context) {
    int healthScore = _calculateHealthScore();

    return Scaffold(
      appBar: AppBar(title: const Text("Health Score Analysis")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Health Score Display
            Center(
              child: Column(
                children: [
                  const Text(
                    "Your Health Score",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: healthScore > 75
                        ? Colors.green
                        : (healthScore > 50 ? Colors.orange : Colors.red),
                    child: Text(
                      "$healthScore",
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    healthScore > 75
                        ? "Excellent Health!"
                        : (healthScore > 50 ? "Moderate Health" : "Needs Improvement"),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Health Breakdown
            _buildHealthStat("BMI", _calculateBMI().toStringAsFixed(1),
                (_calculateBMI() >= 18.5 && _calculateBMI() <= 24.9)),
            _buildEditableStat("Heart Rate", "$heartRate bpm",
                (heartRate >= 60 && heartRate <= 100), (value) {
                  setState(() => heartRate = int.tryParse(value) ?? 75);
                }),
            _buildEditableStat("Sleep Hours", "$sleepHours hrs",
                (sleepHours >= 7 && sleepHours <= 9), (value) {
                  setState(() => sleepHours = int.tryParse(value) ?? 7);
                }),
            _buildEditableStat("Daily Steps", "$steps steps", (steps >= 10000), (value) {
              setState(() => steps = int.tryParse(value) ?? 8000);
            }),

            const SizedBox(height: 20),

            // 🔹 Tips for Improvement
            const Text(
              "Health Improvement Tips",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildTip(healthScore),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthStat(String label, String value, bool isIdeal) {
    return Card(
      child: ListTile(
        leading: Icon(
          isIdeal ? Icons.check_circle : Icons.warning,
          color: isIdeal ? Colors.green : Colors.red,
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }

  Widget _buildEditableStat(String label, String value, bool isIdeal, Function(String) onChanged) {
    return Card(
      child: ListTile(
        leading: Icon(
          isIdeal ? Icons.check_circle : Icons.warning,
          color: isIdeal ? Colors.green : Colors.red,
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: TextFormField(
          initialValue: value.split(" ")[0],
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          decoration: const InputDecoration(border: InputBorder.none),
        ),
      ),
    );
  }

  Widget _buildTip(int score) {
    String tip;
    if (score > 75) {
      tip = "You're doing great! Maintain a balanced diet and stay active.";
    } else if (score > 50) {
      tip = "Focus on improving your sleep and increasing daily activity.";
    } else {
      tip = "Consider consulting a doctor for a detailed health assessment.";
    }
    return Text(tip, style: const TextStyle(fontSize: 16));
  }
}
