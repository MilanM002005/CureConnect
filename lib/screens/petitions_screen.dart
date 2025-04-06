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
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;
  bool _isSubmitting = false;
  String _filterStatus = 'all'; 
  String _searchQuery = '';

  @override
  void dispose() {
    _petitionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _submitPetition() async {
    if (_petitionController.text.trim().isEmpty) return;
    if (_user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You need to be logged in to submit a petition."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _firestore.collection('petitions').add({
        'userId': _user?.uid,
        'userName': _user!.displayName ?? "Anonymous",
        'petition': _petitionController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'acceptedBy': null,
      });

      _petitionController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Petition submitted successfully!"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error submitting petition."),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _acceptPetition(String petitionId) async {
    if (_user == null) return;

    try {
      await _firestore.collection('petitions').doc(petitionId).update({
        'acceptedBy': _user?.uid,
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You have accepted the petition."),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to accept petition."),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _editPetition(String petitionId, String currentText) async {
    final editController = TextEditingController(text: currentText);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Petition"),
          content: TextField(
            controller: editController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "Edit your petition",
              border: OutlineInputBorder(),
            ),
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
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Petition updated successfully!"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.pop(context);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePetition(String petitionId) async {
    final confirmDelete = await showDialog<bool>(
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

    if (confirmDelete == true && mounted) {
      await _firestore.collection('petitions').doc(petitionId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Petition deleted successfully!"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Stream<QuerySnapshot> _getFilteredPetitions() {
    Query query = _firestore
        .collection('petitions')
        .orderBy('timestamp', descending: true);

    
    if (_filterStatus == 'open') {
      query = query.where('acceptedBy', isNull: true);
    } else if (_filterStatus == 'accepted') {
      query = query.where('acceptedBy', isNull: false);
    }

    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(" Petitions"),
        backgroundColor: Colors.redAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Filter Petitions",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            RadioListTile(
                              title: const Text("All Petitions"),
                              value: 'all',
                              groupValue: _filterStatus,
                              onChanged: (value) {
                                setState(() => _filterStatus = value.toString());
                                Navigator.pop(context);
                              },
                            ),
                            RadioListTile(
                              title: const Text("Open Petitions"),
                              value: 'open',
                              groupValue: _filterStatus,
                              onChanged: (value) {
                                setState(() => _filterStatus = value.toString());
                                Navigator.pop(context);
                              },
                            ),
                            RadioListTile(
                              title: const Text("Accepted Petitions"),
                              value: 'accepted',
                              groupValue: _filterStatus,
                              onChanged: (value) {
                                setState(() => _filterStatus = value.toString());
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search petitions...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value.toLowerCase());
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _petitionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Describe your blood donation need...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade200,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _isSubmitting
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _submitPetition,
                      child: const Text(
                        "Submit",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Row(
              children: [
                Text(
                  _filterStatus == 'all'
                      ? "All Petitions"
                      : _filterStatus == 'open'
                      ? "Open Petitions"
                      : "Accepted Petitions",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  "Filter: ${_filterStatus.toUpperCase()}",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getFilteredPetitions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      _filterStatus == 'all'
                          ? "No petitions found."
                          : _filterStatus == 'open'
                          ? "No open petitions."
                          : "No accepted petitions.",
                    ),
                  );
                }

                final petitions = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final petitionText = data['petition'].toString().toLowerCase();
                  final userName = data['userName'].toString().toLowerCase();
                  return petitionText.contains(_searchQuery) ||
                      userName.contains(_searchQuery);
                }).toList();

                if (petitions.isEmpty) {
                  return const Center(child: Text("No matching petitions found."));
                }

                return ListView.builder(
                  itemCount: petitions.length,
                  itemBuilder: (context, index) {
                    final petitionData =
                    petitions[index].data() as Map<String, dynamic>;
                    final petitionId = petitions[index].id;
                    final isOwner = petitionData['userId'] == _user?.uid;
                    final isAccepted = petitionData['acceptedBy'] != null;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.redAccent.withOpacity(0.2),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.redAccent,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  petitionData['userName'] ?? 'Anonymous',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                if (isAccepted)
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.verified,
                                        color: Colors.green,
                                        size: 18,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "Accepted",
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              petitionData['petition'] ?? "No Description",
                              style: const TextStyle(fontSize: 15),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                if (!isAccepted)
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                    ),
                                    onPressed: () => _acceptPetition(petitionId),
                                    child: const Text(
                                      "Accept",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                const Spacer(),
                                if (isOwner)
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (value) {
                                      if (value == "Edit") {
                                        _editPetition(
                                            petitionId, petitionData['petition']);
                                      } else if (value == "Delete") {
                                        _deletePetition(petitionId);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: "Edit",
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, size: 20),
                                            SizedBox(width: 8),
                                            Text("Edit"),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: "Delete",
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text("Delete"),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
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
