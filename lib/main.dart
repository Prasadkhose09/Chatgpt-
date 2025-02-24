import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON encoding and decoding
import 'package:http/http.dart' as http; // For HTTP requests

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gemini Integration',
      home: ChatScreen(),
    );
  }
}

class GeminiService {
  // Your API Key
  final String apiKey = 'A';

  // The model name (e.g., gemini-1.5-flash)
  final String model = 'gemini-1.0-Pro';

  // Function to generate content
  Future<String> generateContent(String prompt) async {
    const apiUrl = 'https://generativelanguage.googleapis.com/v1beta2/models';

    // Endpoint specific to the model
    final endpoint = '$apiUrl/$model:generateText';

    try {
      // Request body
      final requestBody = {
        "prompt": {"text": prompt},
        "temperature": 0.7,
        "candidate_count": 1,
      };

      // Send the POST request
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Parse response
        final responseData = jsonDecode(response.body);
        final generatedText =
            responseData['candidates']?[0]['output'] ?? 'No response generated.';
        return generatedText;
      } else {
        return "Error: ${response.statusCode} - ${response.reasonPhrase}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  String _response = "";

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _response = "Loading..."; // Show loading indicator
      });

      final userMessage = _controller.text;
      // Call the correct function from GeminiService
      final chatResponse = await _geminiService.generateContent(userMessage);

      setState(() {
        _response = chatResponse;
      });

      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gemini Integration")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "Type your message",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sendMessage,
              child: Text("Send"),
            ),
            SizedBox(height: 16),
            Text(
              "Response: $_response",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
