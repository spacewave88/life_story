import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StoryProvider with ChangeNotifier {
  List<Map<String, dynamic>> _segments = [];

  List<Map<String, dynamic>> get segments => _segments;

  Future<void> fetchStory(String uid, Future<String?> tokenFuture) async {
    final token = await tokenFuture;
    if (token != null) {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/users/$uid/story'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        _segments = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        notifyListeners();
      }
    }
  }

  Future<void> saveStory(String uid, String token, Map<String, TextEditingController> controllers) async {
    final updates = controllers.entries.map((e) => {
      '_id': e.key,
      'processedContent': e.value.text,
    }).toList();

    await http.post(
      Uri.parse('http://localhost:3000/api/users/$uid/story'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({'segments': updates}),
    );
    await fetchStory(uid, Future.value(token)); // Refresh
  }
}