import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'hospital_details_screen.dart';

class NearbyHospitalsScreen extends StatefulWidget {
  final Map<String, dynamic> selectedHospital; // Changed to accept full hospital data

  const NearbyHospitalsScreen({
    super.key,
    required this.selectedHospital, // Properly declare required parameter
  });

  @override
  State<NearbyHospitalsScreen> createState() => _NearbyHospitalsScreenState();
}

class _NearbyHospitalsScreenState extends State<NearbyHospitalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Map<String, String>> hospitals; // Moved hospitals list to state

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeHospitals();
  }

  void _initializeHospitals() {
    hospitals = [
      {
        "name": widget.selectedHospital["name"] ?? "Welcare Hospital",
        "image": "assets/hospital1.jpg",
        "mapUrl": "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(widget.selectedHospital["name"] ?? "Hospital")}",
        "bookingUrl": "https://example.com/book-appointment",
        "description": widget.selectedHospital["address"] ?? "Leading healthcare provider",
        "specialties": (widget.selectedHospital["specialties"] as List<dynamic>?)?.join(", ") ?? "General"
      },
      {
        "name": "Lakeshore Hospital",
        "image": "assets/hospital2.jpg",
        "mapUrl": "https://www.google.com/maps/search/?api=1&query=Lakeshore+Hospital",
        "bookingUrl": "https://www.vpslakeshorehospital.com/appointment",
        "description": "Multi-speciality hospital known for advanced medical care",
        "specialties": "General"
      },
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help Close to You", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.pink[300],
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black54,
          tabs: const [
            Tab(text: "Hospitals"),
            Tab(text: "Clinics"),
            Tab(text: "Pharmacy"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHospitalsList(),
          _buildPlaceholder("Clinics"),
          _buildPlaceholder("Pharmacy"),
        ],
      ),
    );
  }

  Widget _buildHospitalsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: hospitals.length,
      itemBuilder: (context, index) {
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                    child: Image.asset(
                      hospitals[index]["image"]!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospitals[index]["name"]!,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hospitals[index]["description"]!,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    if (hospitals[index]["specialties"] != null)
                      Text(
                        "Specialties: ${hospitals[index]["specialties"]}",
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _launchURL(hospitals[index]["mapUrl"]!),
                          child: const Text(
                            "View on Map",
                            style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HospitalDetailsScreen(
                                  name: hospitals[index]["name"]!,
                                  image: hospitals[index]["image"]!,
                                  mapUrl: hospitals[index]["mapUrl"]!,
                                  description: hospitals[index]["description"]!,
                                  bookingUrl: hospitals[index]["bookingUrl"]!,
                                ),
                              ),
                            );
                          },
                          child: const Text("More Details", style: TextStyle(color: Colors.black87)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder(String title) {
    return Center(
      child: Text(
        "$title coming soon...",
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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