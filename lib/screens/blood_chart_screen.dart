import 'package:flutter/material.dart';

class BloodChartScreen extends StatelessWidget {
  const BloodChartScreen({super.key});

  final List<Map<String, String>> bloodCompatibility = const [
    {"type": "O-", "donateTo": "All Blood Types", "receiveFrom": "O-"},
    {"type": "O+", "donateTo": "O+, A+, B+, AB+", "receiveFrom": "O-, O+"},
    {"type": "A-", "donateTo": "A-, A+, AB-, AB+", "receiveFrom": "A-, O-"},
    {"type": "A+", "donateTo": "A+, AB+", "receiveFrom": "A-, A+, O-, O+"},
    {"type": "B-", "donateTo": "B-, B+, AB-, AB+", "receiveFrom": "B-, O-"},
    {"type": "B+", "donateTo": "B+, AB+", "receiveFrom": "B-, B+, O-, O+"},
    {"type": "AB-", "donateTo": "AB-, AB+", "receiveFrom": "AB-, A-, B-, O-"},
    {"type": "AB+", "donateTo": "AB+ (Universal Recipient)", "receiveFrom": "All Blood Types"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Row(
          children: [
            Image.asset(
              'assets/blood_drop.png',
              height: 30,
            ),
            const SizedBox(width: 10),
            const Text(
              "Blood Compatibility Chart",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: bloodCompatibility.length,
          itemBuilder: (context, index) {
            final entry = bloodCompatibility[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: Colors.red.shade50,
                  radius: 24,
                  child: const Icon(Icons.bloodtype, color: Colors.red, size: 28),
                ),
                title: Text(
                  entry["type"]!,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    _InfoRow(title: "Donates To", value: entry["donateTo"]!),
                    _InfoRow(title: "Receives From", value: entry["receiveFrom"]!),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const _InfoRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          text: "$title: ",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
