import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {"icon": Icons.remove_red_eye, "label": "Opthamology"},
      {"icon": Icons.favorite, "label": "Cardiology"},
      {"icon": Icons.medical_services, "label": "Urology"},
      {"icon": Icons.hearing, "label": "ENT"},
      {"icon": Icons.pregnant_woman, "label": "Gynaecology"},
      {"icon": Icons.psychology, "label": "Neurology"},
      {"icon": Icons.child_care, "label": "Paediatrics"},
      {"icon": Icons.local_hospital, "label": "Oncology"},
      {"icon": Icons.person, "label": "Surgeon"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Categories",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          CircleAvatar(
            backgroundColor: Colors.pink.shade100,
            child: const Text("A", style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 20),

            // Categories Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.pink.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(categories[index]["icon"] as IconData,
                            size: 40, color: Colors.black),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        categories[index]["label"] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: 0, // Home tab
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Recommendations"),
          BottomNavigationBarItem(icon: Icon(Icons.login), label: "Login"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}
