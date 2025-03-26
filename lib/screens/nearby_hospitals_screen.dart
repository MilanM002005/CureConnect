import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'hospital_details_screen.dart';

class NearbyHospitalsScreen extends StatefulWidget {
  const NearbyHospitalsScreen({super.key});

  @override
  State<NearbyHospitalsScreen> createState() => _NearbyHospitalsScreenState();
}

class _NearbyHospitalsScreenState extends State<NearbyHospitalsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    List<Map<String, String>> hospitals = [
      {
        "name": "Welcare Hospital",
        "image": "assets/hospital1.jpg",
        "mapUrl": "https://www.google.com/maps/search/?api=1&query=Welcare+Hospital",
        "bookingUrl": "https://welcarehospital.net/book-an-appointment/",
        "description": "Welcare Hospital is a leading healthcare provider offering specialized treatments with state-of-the-art facilities."
      },
      {
        "name": "Lakeshore Hospital",
        "image": "assets/hospital2.jpg",
        "mapUrl": "https://www.google.com/maps/search/?api=1&query=Lakeshore+Hospital",
        "bookingUrl": "https://www.vpslakeshorehospital.com/appointment",
        "description": "Lakeshore Hospital is a multi-speciality hospital in Kochi, known for its advanced medical care and expert doctors."
      },
    ];

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
