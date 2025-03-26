import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DonorDetailsScreen extends StatefulWidget {
  final Map<String, String> donor;
  final String donorId; // Unique donor ID from Firestore

  const DonorDetailsScreen({super.key, required this.donor, required this.donorId});

  @override
  State<DonorDetailsScreen> createState() => _DonorDetailsScreenState();
}

class _DonorDetailsScreenState extends State<DonorDetailsScreen> {
  bool _isRequesting = false; // Loading state for request button

  void _showContactOptions(BuildContext context, String phone) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Contact Donor",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.call, color: Colors.green),
                title: const Text("Call"),
                onTap: () => _launchURL("tel:${widget.donor['phone']}"),
              ),
              ListTile(
                leading: const Icon(Icons.message, color: Colors.blue),
                title: const Text("Message"),
                onTap: () => _launchURL("sms:${widget.donor['phone']}"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint("Could not launch $url");
    }
  }

  Future<void> _requestBlood() async {
    if (_isRequesting) return;
    setState(() => _isRequesting = true);

    try {
      final donorRef = FirebaseFirestore.instance.collection('donors').doc(widget.donorId);

      // Update "requested" field in Firestore
      await donorRef.update({
        'requested': FieldValue.increment(1), // Increment requested count
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Blood request sent successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to send request.")),
      );
    } finally {
      if (mounted) setState(() => _isRequesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 🔹 Profile Header with Modern UI
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red, Colors.deepOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
              ),
              Positioned(
                top: 110,
                child: Column(
                  children: [
                    ClipOval(
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 3)),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage("assets/profile_placeholder.png"),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.donor["name"] ?? "Unknown",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 85,
                right: MediaQuery.of(context).size.width / 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bloodtype, color: Colors.red, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        widget.donor["bloodGroup"] ?? "--",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),

          // 🔹 Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.call, color: Colors.white),
                    label: const Text("Contact", style: TextStyle(color: Colors.white)),
                    onPressed: () => _showContactOptions(context, widget.donor["phone"] ?? ""),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.bloodtype, color: Colors.white),
                    label: _isRequesting
                        ? const SizedBox(
                        height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                        : const Text("Request", style: TextStyle(color: Colors.white)),
                    onPressed: _requestBlood,
                  ),
                ),
              ],
            ),
          ),

          // 🔹 Donor Information
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoCard("Donated", widget.donor["donated"] ?? "0"),
                _infoCard("Requested", widget.donor["requested"] ?? "0"),
              ],
            ),
          ),

          // 🔹 Availability Status
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text("Available for donation", style: TextStyle(fontSize: 16, color: Colors.grey)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
