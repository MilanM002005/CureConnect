import 'package:flutter/material.dart';

class BloodDonationCampsScreen extends StatelessWidget {
  const BloodDonationCampsScreen({super.key});

  final List<Map<String, String>> camps = const [
    {"event": "City Blood Drive", "date": "March 30, 2025", "location": "City Hall", "paid": "Free"},
    {"event": "Red Cross Camp", "date": "April 10, 2025", "location": "Red Cross Center", "paid": "Paid"},
    {"event": "Community Health Fair", "date": "April 20, 2025", "location": "Community Park", "paid": "Free"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Blood Donation Camps"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: camps.length,
        itemBuilder: (context, index) {
          final camp = camps[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.event, color: Colors.red),
              title: Text("${camp['event']} - ${camp['date']}"),
              subtitle: Text("Location: ${camp['location']}"),
              trailing: Text(camp['paid']!, style: TextStyle(color: camp['paid'] == "Free" ? Colors.green : Colors.red)),
            ),
          );
        },
      ),
    );
  }
}
