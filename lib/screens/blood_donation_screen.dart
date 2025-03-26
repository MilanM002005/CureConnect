import 'package:flutter/material.dart';
import 'blood_availability_screen.dart';
import 'blood_donation_camps_screen.dart';
import 'blood_chart_screen.dart';

class BloodDonationScreen extends StatelessWidget {
  const BloodDonationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Blood Donation",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCard(
              context,
              title: "Blood Availability Search",
              icon: Icons.search,
              color: Colors.red.shade100,
              targetScreen: const BloodAvailabilityScreen(),
            ),
            const SizedBox(height: 15),
            _buildCard(
              context,
              title: "Blood Donation Camps",
              icon: Icons.event,
              color: Colors.blue.shade100,
              targetScreen: const BloodDonationCampsScreen(),
            ),
            const SizedBox(height: 15),
            _buildCard(
              context,
              title: "Blood Compatibility Chart",
              icon: Icons.bloodtype,
              color: Colors.green.shade100,
              targetScreen: const BloodChartScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required String title,
        required IconData icon,
        required Color color,
        required Widget targetScreen}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => targetScreen));
        },
      ),
    );
  }
}
