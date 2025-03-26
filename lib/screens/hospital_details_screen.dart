import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HospitalDetailsScreen extends StatelessWidget {
  final String name;
  final String image;
  final String mapUrl;
  final String description;
  final String bookingUrl;

  const HospitalDetailsScreen({
    super.key,
    required this.name,
    required this.image,
    required this.mapUrl,
    required this.description,
    required this.bookingUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              Image.asset(image, height: 220, width: double.infinity, fit: BoxFit.cover),
              Positioned(
                bottom: 10,
                left: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black, blurRadius: 3)],
                      ),
                    ),
                    const Text(
                      "Leading Healthcare Provider",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        shadows: [Shadow(color: Colors.black, blurRadius: 3)],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => _launchURL(mapUrl),
            child: Image.asset("assets/maplakshore.png", height: 200, width: double.infinity, fit: BoxFit.cover),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "About:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(description, style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[300],
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () => _launchURL(bookingUrl),
              child: const Text("Book Now", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIconButton(Icons.call),
              const SizedBox(width: 12),
              _buildIconButton(Icons.share),
              const SizedBox(width: 12),
              _buildIconButton(Icons.info_outline),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.grey[200],
      child: IconButton(
        icon: Icon(icon, color: Colors.black),
        onPressed: () {},
      ),
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $url");
    }
  }
}
