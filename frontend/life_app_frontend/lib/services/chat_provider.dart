
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatProvider with ChangeNotifier {
  List<Map<String, dynamic>> _messages = [
    {'role': 'assistant', 'content': 'Welcome! Let’s share your story.', 'timestamp': DateTime.now().toIso8601String()},
  ];
  final List<String> _questionBank = [
    "What’s a moment you felt truly proud?",
    "Who influenced your early years most?",
    "What was a challenge you faced in university?",
  ];
  int _questionIndex = 0;

  List<Map<String, dynamic>> get messages => _messages;

  void setInitialPrompt(Map<String, String> lifeQuestions) {
    String initialMessage;
    if (lifeQuestions.isNotEmpty) {
      initialMessage = 'You said "${lifeQuestions.values.first}". ${_questionBank[_questionIndex]}';
    } else {
      initialMessage = _questionBank[_questionIndex];
    }
    _messages = [
      {'role': 'assistant', 'content': initialMessage, 'timestamp': DateTime.now().toIso8601String()},
    ];
    _questionIndex = (_questionIndex + 1) % _questionBank.length;
    notifyListeners();
  }

  Future<void> sendMessage(String message, Map<String, String> lifeQuestions, String uid, String token) async {
    try {
      _messages.add({'role': 'user', 'content': message, 'timestamp': DateTime.now().toIso8601String()});
      notifyListeners();

      final prompt = "Ask an introspective follow-up question based on this response: $message";
      final response = await http.post(
        Uri.parse('https://api-inference.huggingface.co/models/distilgpt2'),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['HF_API_TOKEN']}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'inputs': prompt, 'max_length': 50}),
      );

      if (response.statusCode == 200) {
        String aiResponse = jsonDecode(response.body)[0]['generated_text'].replaceFirst(prompt, '').trim();
        _messages.add({
          'role': 'assistant',
          'content': aiResponse,
          'timestamp': DateTime.now().toIso8601String(),
        });
        notifyListeners();

        if (token.isNotEmpty && uid != 'guest') {
          // Post-process and categorize
          final storyPrompt = "Turn this into a cohesive story snippet and suggest a category (e.g., childhood, university): $message";
          final storyResponse = await http.post(
            Uri.parse('https://api-inference.huggingface.co/models/distilgpt2'),
            headers: {
              'Authorization': 'Bearer ${dotenv.env['HF_API_TOKEN']}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'inputs': storyPrompt, 'max_length': 150}),
          );
          if (storyResponse.statusCode == 200) {
            final storyText = jsonDecode(storyResponse.body)[0]['generated_text'].replaceFirst(storyPrompt, '').trim();
            final categoryMatch = RegExp(r'(childhood|university|parenthood)').firstMatch(storyText);
            final category = categoryMatch?.group(0) ?? 'childhood';
            final segmentId = DateTime.now().millisecondsSinceEpoch.toString();

            final segmentResponse = await http.post(
              Uri.parse('http://localhost:3000/api/users/$uid/segments'),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'rawContent': message,
                'processedContent': storyText.split(RegExp(r'(childhood|university|parenthood)'))[0].trim(),
                'category': category,
                'order': _messages.length,
              }),
            );
            if (segmentResponse.statusCode == 200) {
              _messages.last['storySegmentId'] = segmentId;
            } else {
              print('Failed to save story segment: ${segmentResponse.statusCode}');
            }
          } else {
            print('Hugging Face story error: ${storyResponse.statusCode} - ${storyResponse.body}');
          }

          // Save chat history
          final chatResponse = await http.post(
            Uri.parse('http://localhost:3000/api/users/$uid/chat'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'messages': _messages}),
          );
          if (chatResponse.statusCode != 200) {
            print('Failed to save chat: ${chatResponse.statusCode}');
          }
        }
      } else {
        print('Hugging Face error: ${response.statusCode} - ${response.body}');
        _messages.add({
          'role': 'assistant',
          'content': 'Sorry, I couldn’t respond right now.',
          'timestamp': DateTime.now().toIso8601String(),
        });
        notifyListeners();
      }
    } catch (e) {
      print('Error in sendMessage: $e');
      _messages.add({
        'role': 'assistant',
        'content': 'An error occurred. Please try again.',
        'timestamp': DateTime.now().toIso8601String(),
      });
      notifyListeners();
    }
  }
}
