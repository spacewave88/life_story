
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:life_app_frontend/services/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  firebase_auth.User? _user;

  firebase_auth.User? get user => _user;

  bool get isUserLoggedIn => _user != null; // Added getter

  AuthProvider() {
    firebase_auth.FirebaseAuth.instance.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> register(String email, String password, String firstName, String lastName, String dateOfBirth) async {
    try {
      final userCredential = await firebase_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      notifyListeners();

      if (_user != null) {
        // Create user profile in backend
        final response = await http.post(
          Uri.parse('http://localhost:3000/api/users'),
          headers: {
            'Authorization': 'Bearer ${await _user!.getIdToken()}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'firstName': firstName,
            'lastName': lastName,
            'dateOfBirth': dateOfBirth,
          }),
        );

        if (response.statusCode != 201) {
          print('Failed to create user profile: ${response.statusCode} - ${response.body}');
          throw Exception('Failed to create user profile');
        }

        // Sync temporary profile data (e.g., answers from QuestionPage)
        await _syncTempProfileToPermanent(_user!.uid);
      }
    } catch (e) {
      print('Registration error: $e');
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> login(String email, String password, BuildContext context) async {
    try {
      final userCredential = await firebase_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      notifyListeners();
      if (_user != null) {
        // Only sync if tempProfile exists
        final hasTempData = await SharedPreferencesService.areQuestionsCompleted();
        if (hasTempData) {
          await _syncTempProfileToPermanent(_user!.uid);
        }
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      print('Login failed: $e');
      throw Exception('Login failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      await firebase_auth.FirebaseAuth.instance.signOut();
      await SharedPreferencesService.clearTempProfile();
      _user = null;
      notifyListeners();
    } catch (e) {
      print('Logout error: $e');
    }
  }

  Future<void> syncAnswersWithProfile(Map<String, String> answers) async {
    try {
      await SharedPreferencesService.saveTempProfile(answers);
    } catch (e) {
      print('Error syncing answers with profile: $e');
    }
  }

  Future<Map<String, String>> _loadTempProfile() async {
    return await SharedPreferencesService.loadTempProfile();
  }

  Future<void> _clearTempProfile() async {
    await SharedPreferencesService.clearTempProfile();
  }

  Future<void> _syncTempProfileToPermanent(String uid) async {
    final tempProfile = await _loadTempProfile();
    print('Temp profile loaded: $tempProfile'); // Debug log
    if (tempProfile.isNotEmpty) {
      try {
        final isValid = tempProfile.entries.every((entry) => entry.key is String && entry.value is String);
        if (!isValid) {
          print('Invalid temp profile data: $tempProfile');
          await _clearTempProfile();
          return;
        }
        await _savePermanentProfile(uid, tempProfile);
        await _clearTempProfile();
      } catch (e) {
        print('Error syncing temp profile: $e');
      }
    }
  }

  Future<void> _savePermanentProfile(String uid, Map<String, String> profile) async {
    try {
      final idToken = await _user?.getIdToken();
      if (idToken == null) {
        throw Exception('No ID token available');
      }

      final url = Uri.parse('http://localhost:3000/api/users/$uid/profile');
      print('Saving profile to: $url with data: $profile'); // Debug log

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'lifeQuestions': profile}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Failed to save permanent profile: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to save profile: ${response.statusCode} - ${response.body}');
      } else {
        print('Profile saved successfully: ${response.body}');
      }
    } catch (e) {
      print('Error saving permanent profile: $e');
      rethrow;
    }
  }
}