import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID token
  Future<String?> getIdToken() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }

  // Update user profile on backend with additional fields
  Future<void> createUserProfile({
    required String uid, // Add uid parameter
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    Map<String, String>? lifeQuestions, // Optional lifeQuestions
  }) async {
    String? idToken = await getIdToken();
    if (idToken != null) {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/users/$uid/profile'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'dateOfBirth': dateOfBirth,
          if (lifeQuestions != null) 'lifeQuestions': lifeQuestions, // Include if provided
        }),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to update user profile: ${response.statusCode} - ${response.body}');
      }
    } else {
      throw Exception('User not authenticated');
    }
  }

  // Fetch user profile from backend
  Future<Map<String, dynamic>> getUserProfile(String uid) async {
    String? idToken = await getIdToken();
    if (idToken != null) {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/users/$uid'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch user profile: ${response.statusCode}');
      }
      return jsonDecode(response.body)['user']; // Return parsed user data
    } else {
      throw Exception('User not authenticated');
    }
  }

  // Logout method
  Future<void> signOut() async {
    await _auth.signOut();
  }
}