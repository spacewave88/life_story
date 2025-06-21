import 'package:flutter/material.dart';

class AnswersProvider with ChangeNotifier {
  final Map<String, String> _answers = {}; // Key: question, Value: answer

  Map<String, String> get answers => Map.unmodifiable(_answers); // Read-only access

  void updateAnswer(String question, String answer) {
    if (question.isNotEmpty && answer.isNotEmpty) { // Basic validation
      _answers[question] = answer;
      notifyListeners();
    } else {
      print('Invalid question or answer skipped: $question -> $answer');
    }
  }

  void clearAnswers() {
    _answers.clear();
    notifyListeners();
  }

  // Method to merge with existing answers (for syncing with temp/permanent profiles)
  void mergeAnswers(Map<String, dynamic> newAnswers) {
    if (newAnswers.isNotEmpty) {
      final validAnswers = <String, String>{};
      newAnswers.forEach((key, value) {
        if (key is String && value is String) {
          validAnswers[key] = value;
        } else {
          print('Skipping invalid answer: $key -> $value');
        }
      });
      _answers.addAll(validAnswers);
      notifyListeners();
    }
  }

  // Method to export answers for syncing with backend or local storage
  Map<String, String> exportAnswers() {
    return Map<String, String>.from(_answers); // Clean copy
  }
}