import 'package:flutter/material.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _showHistory = false;

  final Map<String, List<String>> diseaseSymptoms = {
    "Common Cold": ["sneezing", "runny nose", "sore throat", "mild fever"],
    "Influenza (Flu)": ["chills", "muscle pain", "fatigue"],
    "COVID-19": ["fever", "cough", "breathlessness", "loss of taste"],
    "Pneumonia": ["cough", "chest pain", "difficulty breathing", "high fever"],
    "Tuberculosis": ["persistent cough", "night sweats", "weight loss"],
    "Malaria": ["fever", "chills", "sweating", "muscle pain"],
    "Measles": ["rash", "high fever", "red eyes", "runny nose"],
    "Chickenpox": ["itchy rash", "aches and pains", "loss of appetite"],
    "Meningitis": ["stiff neck", "high fever", "headache", "confusion"],
    "Hepatitis": ["jaundice", "fatigue", "abdominal pain", "nausea"],
  };

  void _sendMessage() {
    String userMessage = _controller.text.trim().toLowerCase();
    if (userMessage.isNotEmpty) {
      setState(() {
        _messages.add({"sender": "user", "message": _controller.text});
      });

      _controller.clear();

      Future.delayed(const Duration(seconds: 1), () {
        _botResponse(userMessage);
      });
    }
  }

  void _botResponse(String userMessage) {
    List<String> possibleDiseases = [];

    diseaseSymptoms.forEach((disease, symptoms) {
      for (String symptom in symptoms) {
        if (userMessage.contains(symptom)) {
          possibleDiseases.add(disease);
          break;
        }
      }
    });

    String botReply = possibleDiseases.isNotEmpty
        ? "Based on your symptoms, you might have:\n• ${possibleDiseases.join("\n• ")}.\n\nPlease consult a doctor for accurate diagnosis."
        : "I'm here to help! Can you describe your symptoms in more detail?";

    setState(() {
      _messages.add({"sender": "bot", "message": botReply});
    });
  }

  Widget _buildHistoryItem(String title, String date, String symptoms) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: const Icon(Icons.chat_bubble_outline, color: Colors.pinkAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date),
            Text("Symptoms: $symptoms", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        onTap: () {
          setState(() {
            _showHistory = false;
            _messages.clear();
            _messages.addAll([
              {"sender": "user", "message": "Tell me about $symptoms"},
              {"sender": "bot", "message": "Here's our previous discussion about $title"},
            ]);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome to CureConnect"),
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
      body: Stack(
        children: [
          Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search symptoms, diseases, treatment...",
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
              ),

              // Chat Area
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        spreadRadius: 2,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Chat Header
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.pinkAccent,
                              child: Icon(Icons.medical_services, color: Colors.white),
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Medibot",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.circle, color: Colors.green, size: 10),
                                    SizedBox(width: 5),
                                    Text("Online", style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.history, color: Colors.black),
                              onPressed: () => setState(() => _showHistory = !_showHistory),
                            ),
                          ],
                        ),
                      ),

                      // Messages Display
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ListView.builder(
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              bool isUser = _messages[index]['sender'] == "user";
                              return Align(
                                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 5),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isUser ? Colors.pinkAccent : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _messages[index]['message']!,
                                    style: TextStyle(color: isUser ? Colors.white : Colors.black),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Input Field
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                decoration: InputDecoration(
                                  hintText: "Describe your symptoms...",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pinkAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              ),
                              onPressed: _sendMessage,
                              child: const Text("Send", style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // History Panel
          if (_showHistory)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: MediaQuery.of(context).size.width * 0.7,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => setState(() => _showHistory = false),
                        ),
                        const Text(
                          "Chat History",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView(
                        children: [
                          _buildHistoryItem("Fever Consultation", "Yesterday", "fever, headache"),
                          _buildHistoryItem("Headache Discussion", "Last week", "migraine, nausea"),
                          _buildHistoryItem("Cold Symptoms", "2 weeks ago", "runny nose, sneezing"),
                          _buildHistoryItem("Allergy Concerns", "3 days ago", "rash, itching"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}