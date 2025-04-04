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

  void _launchFirstAidTips() async {
    final Uri url = Uri.parse("https://www.healthdirect.gov.au/first-aid-advice");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch First Aid Tips");
    }
  }

  void _callAmbulance() async {
    final Uri url = Uri.parse("tel:+917994622820");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      debugPrint("Could not launch dialer.");
    }
  }

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
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Location shared with emergency contacts")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final buttonColor = isDarkMode
        ? Colors.pink.shade900.withOpacity(0.3)
        : Colors.pink.shade100;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Emergency Help"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.1, // Better aspect ratio for buttons
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildEmergencyButton(
              context,
              icon: Icons.call,
              label: "Call Ambulance",
              color: buttonColor,
              iconColor: Colors.redAccent,
              onTap: _callAmbulance,
            ),
            _buildEmergencyButton(
              context,
              icon: Icons.local_hospital,
              label: "Nearest Hospital",
              color: buttonColor,
              iconColor: Colors.blue,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const NearbyHospitalsScreen(selectedHospital: {},))),
            ),
            _buildEmergencyButton(
              context,
              icon: Icons.medical_services,
              label: "First Aid Tips",
              color: buttonColor,
              iconColor: Colors.green,
              onTap: _launchFirstAidTips,
            ),
            _buildEmergencyButton(
              context,
              icon: Icons.location_on,
              label: "Live Location",
              color: buttonColor,
              iconColor: Colors.orange,
              onTap: () => _shareLiveLocation(context),
            ),
            _buildEmergencyButton(
              context,
              icon: Icons.bloodtype,
              label: "Blood Donation",
              color: buttonColor,
              iconColor: Colors.red,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const BloodDonationScreen())),
            ),
            _buildEmergencyButton(
              context,
              icon: Icons.contacts,
              label: "Emergency Contacts",
              color: buttonColor,
              iconColor: Colors.purple,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const EmergencyContactsScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
        required Color iconColor,
        VoidCallback? onTap,
      }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: iconColor),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}