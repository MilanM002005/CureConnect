import 'package:flutter/material.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedTreatments = [];

  void _toggleTreatment(String treatment) {
    setState(() {
      if (_selectedTreatments.contains(treatment)) {
        _selectedTreatments.remove(treatment);
      } else {
        _selectedTreatments.add(treatment);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Recommendation'),
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
                hintText: "Search diseases, treatment...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Treatment Selection
            const Text("Types of treatment", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 10,
              children: ["Chemotherapy", "X-ray", "PET Scan"].map((treatment) {
                bool isSelected = _selectedTreatments.contains(treatment);
                return GestureDetector(
                  onTap: () => _toggleTreatment(treatment),
                  child: Chip(
                    label: Text(treatment),
                    backgroundColor: isSelected ? Colors.pink.shade100 : Colors.grey.shade200,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Analyze Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Add logic to fetch hospitals
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Analyze", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),

            // Bottom Text
            const Center(
              child: Text(
                "Looking for medical care? Find the best hospitals with specialized facilities for your treatment journey.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
