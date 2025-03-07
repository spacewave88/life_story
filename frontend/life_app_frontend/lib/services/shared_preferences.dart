import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPreferencesService {
  static const String _tempProfileKey = 'tempProfile'; // Key for storing temporary profile data

  // Save temporary profile data (e.g., question answers)
  static Future<void> saveTempProfile(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tempProfileKey, jsonEncode(profile));
  }

  // Load temporary profile data
  static Future<Map<String, dynamic>> loadTempProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tempProfileJson = prefs.getString(_tempProfileKey);
    if (tempProfileJson != null) {
      return jsonDecode(tempProfileJson) as Map<String, dynamic>;
    }
    return {};
  }

  // Clear temporary profile data
  static Future<void> clearTempProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tempProfileKey);
  }
}