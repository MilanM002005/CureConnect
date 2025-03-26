import 'package:flutter/material.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  final Map<String, List<String>> diseaseSymptoms = {
    "Common Cold": ["sneezing", "runny nose", "sore throat", "mild fever"],
    "Influenza (Flu)": [ "chills", "muscle pain", "fatigue"],
    "COVID-19": ["fever", "cough", "breathlessness", "loss of taste"],
    "Pneumonia": ["cough", "chest pain", "difficulty breathing", "high fever"],
    "Tuberculosis": ["persistent cough", "night sweats", "weight loss"],
    "Malaria": ["fever", "chills", "sweating", "muscle pain"],
    "Measles": ["rash", "high fever", "red eyes", "runny nose"],
    "Chickenpox": ["itchy rash", "Aches and pains", "Loss of appetite"],
    "Meningitis": ["stiff neck", "high fever", "headache", "confusion"],
    "Hepatitis": ["jaundice", "fatigue", "abdominal pain", "nausea"],
    "Heart Disease": ["chest pain", "shortness of breath", "fatigue"],
    "Stroke": ["numbness", "loss of vision", "slurred speech"],
    "High Blood Pressure": ["headache", "dizziness", "blurred vision"],
  };

  void _sendMessage() {
    String userMessage = _controller.text.trim().toLowerCase();
    if (userMessage.isNotEmpty) {
      setState(() {
        _messages.add({"sender": "user", "message": _controller.text});
      });

      _controller.clear();

      // ✅ Simulate bot response
      Future.delayed(const Duration(seconds: 1), () {
        _botResponse(userMessage);
      });
    }
  }

  void _botResponse(String userMessage) {
    List<String> possibleDiseases = [];

    // ✅ Match input symptoms with diseases
    diseaseSymptoms.forEach((disease, symptoms) {
      for (String symptom in symptoms) {
        if (userMessage.contains(symptom)) {
          possibleDiseases.add(disease);
          break; // Prevent duplicate disease suggestions
        }
      }
    });

    String botReply;
    if (possibleDiseases.isNotEmpty) {
      botReply = "Based on your symptoms, you might have:\n• ${possibleDiseases.join("\n• ")}.\nPlease consult a doctor for an accurate diagnosis.";
    } else {
      botReply = "I'm here to help! Can you describe your symptoms in more detail?";
    }

    setState(() {
      _messages.add({"sender": "bot", "message": botReply});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Welcome to CureConnect",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
      body: Column(
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

          // Chat UI
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chat Header
                    Row(
                      children: [
                        const Icon(Icons.menu, color: Colors.black),
                        const SizedBox(width: 10),
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
                          icon: const Icon(Icons.close, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Chat Messages Display
                    Expanded(
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
                                color: isUser ? Colors.pinkAccent : Colors.grey[300],
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

                    const SizedBox(height: 10),

                    // Input Field
                    Row(
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
