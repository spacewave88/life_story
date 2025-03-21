import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatProvider with ChangeNotifier {
  List<Map<String, dynamic>> _messages = [
    {'role': 'assistant', 'content': 'Welcome! Let’s share your story.'},
  ];

  List<Map<String, dynamic>> get messages => _messages;

  Future<void> sendMessage(String message, Map<String, String> lifeQuestions, String uid, String token) async {
    _messages.add({'role': 'user', 'content': message, 'timestamp': DateTime.now().toIso8601String()});
    notifyListeners();

    // Hugging Face API call (distilgpt2)
    final prompt = "Based on these answers: ${jsonEncode(lifeQuestions)}, respond to: $message";
    final response = await http.post(
      Uri.parse('https://api-inference.huggingface.co/models/distilgpt2'),
      headers: {
        'Authorization': 'Bearer ${dotenv.env['HF_API_TOKEN']}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'inputs': prompt, 'max_length': 100}),
    );

    if (response.statusCode == 200) {
      final aiResponse = jsonDecode(response.body)[0]['generated_text'];
      _messages.add({'role': 'assistant', 'content': aiResponse, 'timestamp': DateTime.now().toIso8601String()});
      notifyListeners();

      // Save to backend
      await http.post(
        Uri.parse('http://localhost:3000/api/users/$uid/chat'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'messages': _messages}),
      );
    } else {
      print('Hugging Face error: ${response.statusCode} - ${response.body}');
      _messages.add({'role': 'assistant', 'content': 'Sorry, I couldn’t respond right now.'});
      notifyListeners();
    }
  }

  void setInitialPrompt(Map<String, String> lifeQuestions) {
    if (lifeQuestions.isNotEmpty) {
      _messages.add({
        'role': 'assistant',
        'content': 'You said "${lifeQuestions.values.first}". Tell me more about that!',
      });
      notifyListeners();
    }
  }
}