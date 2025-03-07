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

  // Create user profile on backend with additional fields
  Future<void> createUserProfile({
    required String firstName,
    required String lastName,
    required String dateOfBirth,
  }) async {
    String? idToken = await getIdToken();
    if (idToken != null) {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/users'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'dateOfBirth': dateOfBirth,
        }),
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to create user profile: ${response.statusCode}');
      }
    } else {
      throw Exception('User not authenticated');
    }
  }

  // Fetch user profile from backend
  Future<void> getUserProfile(String uid) async {
    String? idToken = await getIdToken();
    if (idToken != null) {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/users/$uid'), // USING LOCAL HOST, CHANGE IF HOST CHANGES
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch user profile');
      }
      // Handle response data (e.g., parse JSON and use it)
    } else {
      throw Exception('User not authenticated');
    }
  }
  // Logout method
  Future<void> signOut() async {
    await _auth.signOut();
  }  
}