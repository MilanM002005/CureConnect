import 'package:flutter/material.dart';
import 'nearby_hospitals_screen.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedTreatments = [];
  bool _isLoading = false;
  List<Map<String, dynamic>> _recommendedHospitals = [];

  final List<String> _allTreatments = [
    "Chemotherapy",
    "X-ray",
    "PET Scan",
    "MRI",
    "Cardiology",
    "Neurology",
    "Pediatrics",
    "Orthopedics",
    "Dermatology",
    "Oncology"
  ];

  void _toggleTreatment(String treatment) {
    setState(() {
      if (_selectedTreatments.contains(treatment)) {
        _selectedTreatments.remove(treatment);
      } else {
        _selectedTreatments.add(treatment);
      }
    });
  }

  Future<void> _analyzeRecommendations() async {
    if (_selectedTreatments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please select at least one treatment type"),
          backgroundColor: Colors.pink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock data - filtered by selected treatments
    setState(() {
      _recommendedHospitals = [
        {
          "name": "City General Hospital",
          "distance": "2.5 km",
          "rating": 4.7,
          "specialties": ["Chemotherapy", "Oncology"],
          "address": "123 Medical Drive, City Center",
          "image": "assets/hospital1.jpg",
        },
        {
          "name": "Sunshine Medical Center",
          "distance": "3.8 km",
          "rating": 4.5,
          "specialties": ["X-ray", "MRI"],
          "address": "456 Health Avenue, Downtown",
          "image": "assets/hospital2.jpg",
        },
        {
          "name": "Prestige Healthcare",
          "distance": "5.2 km",
          "rating": 4.8,
          "specialties": ["PET Scan", "Neurology"],
          "address": "789 Wellness Boulevard",
          "image": "assets/hospital3.jpg",
        },
      ].where((hospital) {
        final specialties = hospital["specialties"] as List<String>;
        return _selectedTreatments.any((treatment) => specialties.contains(treatment));
      }).toList();

      _isLoading = false;
    });
  }

  void _navigateToHospital(Map<String, dynamic> hospital) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NearbyHospitalsScreen(
          selectedHospital: hospital,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Recommendations'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search diseases, treatments...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_alt),
                  onPressed: () {},
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Treatment Selection
            const Text(
              "Select Treatment Types",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allTreatments.map((treatment) {
                bool isSelected = _selectedTreatments.contains(treatment);
                return ChoiceChip(
                  label: Text(treatment),
                  selected: isSelected,
                  onSelected: (selected) => _toggleTreatment(treatment),
                  selectedColor: Colors.pink.shade100,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.pink.shade800 : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Analyze Button
            Center(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _analyzeRecommendations,
                icon: _isLoading
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.analytics_outlined),
                label: Text(
                  _isLoading ? "Analyzing..." : "Find Hospitals",
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Results Section
            if (_recommendedHospitals.isNotEmpty) ...[
              const Text(
                "Recommended Hospitals",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _recommendedHospitals.length,
                  itemBuilder: (context, index) {
                    final hospital = _recommendedHospitals[index];
                    return _buildHospitalCard(hospital);
                  },
                ),
              ),
            ] else if (_isLoading) ...[
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.pinkAccent,
                  ),
                ),
              ),
            ] else ...[
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_hospital_outlined,
                        size: 60,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Find specialized hospitals for your treatment needs",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalCard(Map<String, dynamic> hospital) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToHospital(hospital),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    hospital["name"],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        hospital["rating"].toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.local_hospital,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    hospital["address"],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    hospital["distance"],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (hospital["specialties"] as List).map((specialty) {
                  return Chip(
                    label: Text(specialty),
                    backgroundColor: Colors.pink.shade50,
                    labelStyle: TextStyle(
                      color: Colors.pink.shade800,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _navigateToHospital(hospital),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "View Details",
                        style: TextStyle(color: Colors.pinkAccent),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Colors.pinkAccent,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}