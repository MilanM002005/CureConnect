import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class PetitionsScreen extends StatefulWidget {
  const PetitionsScreen({super.key});

  @override
  State<PetitionsScreen> createState() => _PetitionsScreenState();
}

class _PetitionsScreenState extends State<PetitionsScreen> {
  final TextEditingController _petitionController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;
  bool _isSubmitting = false;

  Future<void> _submitPetition() async {
    if (_petitionController.text.trim().isEmpty) return;
    if (_user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You need to be logged in to submit a petition.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _firestore.collection('petitions').add({
        'userId': _user.uid,
        'userName': _user.displayName ?? "Anonymous",
        'petition': _petitionController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'acceptedBy': null,
      });

      _petitionController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Petition submitted successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error submitting petition.")),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _acceptPetition(String petitionId) async {
    if (_user == null) return;

    try {
      await _firestore.collection('petitions').doc(petitionId).update({
        'acceptedBy': _user.uid,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You have accepted the petition.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to accept petition.")),
      );
    }
  }

  Future<void> _editPetition(String petitionId, String currentText) async {
    TextEditingController editController = TextEditingController(text: currentText);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Petition"),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(hintText: "Edit your petition"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (editController.text.trim().isNotEmpty) {
                  await _firestore.collection('petitions').doc(petitionId).update({
                    'petition': editController.text.trim(),
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Petition updated successfully!")),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePetition(String petitionId) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Petition"),
          content: const Text("Are you sure you want to delete this petition?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Delete", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      await _firestore.collection('petitions').doc(petitionId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Petition deleted successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Petitions"),
        backgroundColor: Colors.redAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()), // ✅ Navigates to Home
            );
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _petitionController,
                    decoration: InputDecoration(
                      hintText: "Describe your problem...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _isSubmitting
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  onPressed: _submitPetition,
                  child: const Text("Submit", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('petitions')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No petitions found."));
                }

                final petitions = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: petitions.length,
                  itemBuilder: (context, index) {
                    final petitionData = petitions[index].data() as Map<String, dynamic>;
                    final petitionId = petitions[index].id;
                    final bool isOwner = petitionData['userId'] == _user?.uid;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        title: Text(
                          petitionData['petition'] ?? "No Description",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "By: ${petitionData['userName'] ?? 'Anonymous'}",
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (petitionData['acceptedBy'] == null)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                onPressed: () => _acceptPetition(petitionId),
                                child: const Text("Accept", style: TextStyle(color: Colors.white)),
                              )
                            else
                              const Icon(Icons.check_circle, color: Colors.green),

                            // 🔹 Three-dot menu for Edit/Delete (Only for owner)
                            if (isOwner)
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == "Edit") {
                                    _editPetition(petitionId, petitionData['petition']);
                                  } else if (value == "Delete") {
                                    _deletePetition(petitionId);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: "Edit", child: Text("Edit")),
                                  const PopupMenuItem(value: "Delete", child: Text("Delete")),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
