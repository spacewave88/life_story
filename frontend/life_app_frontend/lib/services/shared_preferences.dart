
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPreferencesService {
  static const String _tempProfileKey = 'tempProfile'; // Key for storing temporary profile data
  static const String _questionsCompletedKey = 'questionsCompleted'; // Key for tracking question completion
  static const String _hasTempDataKey = 'hasTempData'; // Key for tracking presence of temp data

  // Save temporary profile data (e.g., question answers)
  static Future<void> saveTempProfile(Map<String, String> profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tempProfileKey, jsonEncode(profile));
      await prefs.setBool(_hasTempDataKey, true); // Set flag to indicate temp data exists
      print('Temp profile saved: $profile'); // Debug log
    } catch (e) {
      print('Error saving temp profile: $e');
    }
  }

  // Load temporary profile data
  static Future<Map<String, String>> loadTempProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? tempProfileJson = prefs.getString(_tempProfileKey);
      if (tempProfileJson == null) {
        print('No temp profile found'); // Debug log
        return {};
      }
      final profile = jsonDecode(tempProfileJson);
      if (profile is Map) {
        // Ensure all keys and values are strings
        final validProfile = Map<String, String>.fromEntries(
          profile.entries.where((e) => e.key is String && e.value is String).map((e) => MapEntry(e.key as String, e.value as String)),
        );
        print('Temp profile loaded: $validProfile'); // Debug log
        return validProfile;
      }
      print('Invalid temp profile format: $profile');
      await clearTempProfile(); // Clear invalid data
      return {};
    } catch (e) {
      print('Error loading temp profile: $e');
      await clearTempProfile(); // Clear invalid data on error
      return {};
    }
  }

  // Clear temporary profile data
  static Future<void> clearTempProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final removedProfile = await prefs.remove(_tempProfileKey);
      final removedFlag = await prefs.remove(_hasTempDataKey);
      print('Temp profile cleared: profile=$removedProfile, hasTempData=$removedFlag'); // Debug log
    } catch (e) {
      print('Error clearing temp profile: $e');
    }
  }

  // Set questions completed flag
  static Future<void> setQuestionsCompleted(bool completed) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_questionsCompletedKey, completed);
      print('Questions completed set: $completed'); // Debug log
    } catch (e) {
      print('Error setting questions completed: $e');
    }
  }

  // Check if questions are completed
  static Future<bool> areQuestionsCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasTempData = prefs.getBool(_hasTempDataKey) ?? false;
      print('Questions completed check: $hasTempData'); // Debug log
      return hasTempData;
    } catch (e) {
      print('Error checking questions completed: $e');
      return false;
    }
  }
}