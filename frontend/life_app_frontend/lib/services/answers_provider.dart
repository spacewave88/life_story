import 'package:flutter/material.dart';

class AnswersProvider with ChangeNotifier {
  final Map<String, String> _answers = {}; // Key: question, Value: answer

  Map<String, String> get answers => Map.unmodifiable(_answers); // Read-only access

  void updateAnswer(String question, String answer) {
    _answers[question] = answer;
    notifyListeners(); // Notify listeners of change
  }

  void clearAnswers() {
    _answers.clear();
    notifyListeners(); // Notify listeners after clearing
  }

  // Method to merge with existing answers (for syncing with temp/permanent profiles)
  void mergeAnswers(Map<String, dynamic> newAnswers) {
    _answers.addAll(Map<String, String>.from(newAnswers));
    notifyListeners();
  }

  // Method to export answers for syncing with backend or local storage
  Map<String, String> exportAnswers() {
    return Map<String, String>.from(_answers);
  }
}