import 'package:flutter/material.dart';
import 'donor_details_screen.dart';

class BloodAvailabilityScreen extends StatefulWidget {
  const BloodAvailabilityScreen({super.key});

  @override
  BloodAvailabilityScreenState createState() => BloodAvailabilityScreenState();
}

class BloodAvailabilityScreenState extends State<BloodAvailabilityScreen> {
  List<Map<String, String>> donors = [
    {
      "donorId": "1",
      "name": "John Doe",
      "bloodGroup": "A+",
      "age": "28",
      "location": "New Delhi",
      "urgency": "High",
      "donated": "2",
      "requested": "5"
    },
    {
      "donorId": "2",
      "name": "Emily Carter",
      "bloodGroup": "O-",
      "age": "32",
      "location": "Mumbai",
      "urgency": "Medium",
      "donated": "1",
      "requested": "3"
    },
    {
      "donorId": "3",
      "name": "Michael Smith",
      "bloodGroup": "B+",
      "age": "45",
      "location": "Bangalore",
      "urgency": "High",
      "donated": "4",
      "requested": "6"
    },
  ];

  void _addNewDonor(String name, String bloodGroup, String age, String location, String urgency) {
    setState(() {
      donors.add({
        "donorId": DateTime.now().millisecondsSinceEpoch.toString(),
        "name": name,
        "bloodGroup": bloodGroup,
        "age": age,
        "location": location,
        "urgency": urgency,
        "donated": "0",
        "requested": "0"
      });
    });
    Navigator.pop(context);
  }

  void _showAddDonorDialog() {
    String name = '', bloodGroup = '', age = '', location = '', urgency = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Donor"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Name"),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Blood Group"),
                onChanged: (value) => bloodGroup = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Age"),
                keyboardType: TextInputType.number,
                onChanged: (value) => age = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Location"),
                onChanged: (value) => location = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Urgency (High/Medium/Low)"),
                onChanged: (value) => urgency = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (name.isNotEmpty && bloodGroup.isNotEmpty && age.isNotEmpty && location.isNotEmpty && urgency.isNotEmpty) {
                  _addNewDonor(name, bloodGroup, age, location, urgency);
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
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
          // 🔹 Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                hintText: "Search for donors or requests...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 Hero Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/donate_blood_banner.jpg',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 Blood Requests List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: donors.length,
              itemBuilder: (context, index) {
                final donor = donors[index];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/blood_drop.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      "${donor["bloodGroup"]} Blood Needed",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${donor["name"]}, ${donor["age"]} years old\nLocation: ${donor["location"]}, Urgency: ${donor["urgency"]}",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DonorDetailsScreen(
                              donorId: donor["donorId"]!,
                              donor: donor,
                            ),
                          ),
                        );
                      },
                      child: const Text("Donate Now"),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDonorDialog,
        backgroundColor: Colors.red,
        child: const Icon(Icons.water_drop, color: Colors.white),
      ),
    );
  }
}
