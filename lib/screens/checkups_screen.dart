import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckupsScreen extends StatelessWidget {
   CheckupsScreen({super.key});

  final List<Map<String, String>> checkupEvents = [
    {
      "title": "Cancer Treatment Camp",
      "doctor": "Dr. Robert Williams",
      "date": "April 5, 2025",
      "time": "10:00 AM - 4:00 PM",
      "location": "https://maps.google.com/?q=Cancer+Treatment+Camp",
      "cost": "Free"
    },
    {
      "title": "Blood Donation Camp",
      "doctor": "Dr. Emily Carter",
      "date": "April 10, 2025",
      "time": "09:00 AM - 5:00 PM",
      "location": "https://maps.google.com/?q=Blood+Donation+Camp",
      "cost": "Free"
    },
    {
      "title": "Eye Treatment Camp",
      "doctor": "Dr. Michael Johnson",
      "date": "April 15, 2025",
      "time": "08:30 AM - 3:00 PM",
      "location": "https://maps.google.com/?q=Eye+Treatment+Camp",
      "cost": "Paid"
    },
    {
      "title": "Dental Checkup Camp",
      "doctor": "Dr. Sarah Thompson",
      "date": "April 20, 2025",
      "time": "10:00 AM - 4:00 PM",
      "location": "https://maps.google.com/?q=Dental+Checkup+Camp",
      "cost": "Free"
    },
    {
      "title": "Heart Checkup Camp",
      "doctor": "Dr. Andrew Martinez",
      "date": "April 25, 2025",
      "time": "09:00 AM - 2:00 PM",
      "location": "https://maps.google.com/?q=Heart+Checkup+Camp",
      "cost": "Paid"
    },
    {
      "title": "Diabetes Screening Camp",
      "doctor": "Dr. Laura Green",
      "date": "May 2, 2025",
      "time": "08:00 AM - 1:00 PM",
      "location": "https://maps.google.com/?q=Diabetes+Screening+Camp",
      "cost": "Free"
    },
    {
      "title": "Orthopedic Consultation Camp",
      "doctor": "Dr. Richard Brown",
      "date": "May 8, 2025",
      "time": "10:00 AM - 5:00 PM",
      "location": "https://maps.google.com/?q=Orthopedic+Consultation+Camp",
      "cost": "Paid"
    },
    {
      "title": "Mental Health Awareness Camp",
      "doctor": "Dr. Sophia Miller",
      "date": "May 15, 2025",
      "time": "11:00 AM - 3:00 PM",
      "location": "https://maps.google.com/?q=Mental+Health+Camp",
      "cost": "Free"
    },
    {
      "title": "Vaccination Drive",
      "doctor": "Dr. Kevin Parker",
      "date": "May 22, 2025",
      "time": "09:30 AM - 4:30 PM",
      "location": "https://maps.google.com/?q=Vaccination+Drive",
      "cost": "Free"
    },
    {
      "title": "Skin Treatment Camp",
      "doctor": "Dr. Amanda White",
      "date": "May 30, 2025",
      "time": "10:00 AM - 5:00 PM",
      "location": "https://maps.google.com/?q=Skin+Treatment+Camp",
      "cost": "Paid"
    },
  ];

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not open location link");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkups"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to HomeScreen
          },
        ),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Upcoming Checkups & Health Camps",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: checkupEvents.length,
                itemBuilder: (context, index) {
                  final event = checkupEvents[index];
                  return _buildCheckupCard(
                    event["title"]!,
                    event["doctor"]!,
                    event["date"]!,
                    event["time"]!,
                    event["location"]!,
                    event["cost"]!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckupCard(
      String title, String doctor, String date, String time, String location, String cost) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.local_hospital, color: Colors.pinkAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Dr. $doctor\n$date - $time"),
            Text(
              "Cost: $cost",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: cost == "Free" ? Colors.green : Colors.red,
              ),
            ),
            GestureDetector(
              onTap: () => _launchURL(location),
              child: const Text(
                "View Location",
                style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }
}
