import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'emergency_contacts_screen.dart';
import 'nearby_hospitals_screen.dart';
import 'blood_donation_screen.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  // ✅ Launch First Aid Tips Link
  void _launchFirstAidTips() async {
    final Uri url = Uri.parse("https://www.healthdirect.gov.au/first-aid-advice");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch First Aid Tips");
    }
  }

  // ✅ Call Ambulance (Dial Number)
  void _callAmbulance() async {
    final Uri url = Uri.parse("tel:+917994622820");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      debugPrint("Could not launch dialer.");
    }
  }

  // ✅ Share Live Location with Emergency Contacts
  Future<void> _shareLiveLocation(BuildContext context) async {
    final location = Location();

    if (!await location.serviceEnabled()) {
      if (!await location.requestService()) return;
    }

    final permission = await location.requestPermission();
    if (permission != PermissionStatus.granted) return;

    final locationData = await location.getLocation();
    final String locationUrl = "https://www.google.com/maps?q=${locationData.latitude},${locationData.longitude}";

    if (!context.mounted) return;
    final authService = Provider.of<AuthService>(context, listen: false);
    final contactsStream = authService.getUserEmergencyContacts();

    contactsStream.first.then((contacts) {
      for (var contact in contacts) {
        debugPrint("Sending location to ${contact['name']} at ${contact['phone']}: $locationUrl");
        // Logic for sending via SMS or push notification goes here
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Location shared with emergency contacts")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Emergency Help",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _buildEmergencyButton(Icons.call, "Call Ambulance", onTap: _callAmbulance),
            _buildEmergencyButton(
              Icons.home,
              "Nearest Hospital",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NearbyHospitalsScreen()));
              },
            ),
            _buildEmergencyButton(
              Icons.help_outline,
              "First Aid Tips",
              onTap: _launchFirstAidTips,
            ),
            _buildEmergencyButton(
              Icons.location_on,
              "Live Location Sharing",
              onTap: () => _shareLiveLocation(context),
            ),
            _buildEmergencyButton(
              Icons.volunteer_activism,
              "Blood Donation",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BloodDonationScreen()));
              },
            ),
            _buildEmergencyButton(
              Icons.contacts,
              "Emergency Contacts",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyContactsScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyButton(IconData icon, String label, {VoidCallback? onTap}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.pink.shade100,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onTap ?? () {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.redAccent),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
