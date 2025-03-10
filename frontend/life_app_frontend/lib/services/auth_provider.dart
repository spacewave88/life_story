import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:life_app_frontend/services/answers_provider.dart';
import 'package:life_app_frontend/services/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  firebase_auth.User? _user;

  firebase_auth.User? get user => _user;

  AuthProvider() {
    _initializeAuthState();
  }

  Future<void> _initializeAuthState() async {
    _user = firebase_auth.FirebaseAuth.instance.currentUser;
    firebase_auth.FirebaseAuth.instance.authStateChanges().listen((firebase_auth.User? user) async {
      _user = user;
      notifyListeners();
      if (user != null) {
        await _syncTempProfileToPermanent(user.uid);
      }
    });
  }

  bool get isUserLoggedIn => _user != null;

  Future<void> login(String email, String password, BuildContext context) async {
    try {
      final userCredential = await firebase_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      notifyListeners();
      if (_user != null) {
        await _syncTempProfileToPermanent(_user!.uid);
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> register(String email, String password, BuildContext context) async {
    try {
      final userCredential = await firebase_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      if (_user == null) {
        throw Exception('User creation failed: No user returned');
      }
      notifyListeners();

      final tempProfile = await _loadTempProfile();
      if (tempProfile.isNotEmpty) {
        await _savePermanentProfile(_user!.uid, tempProfile);
      }
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (e) {
      print('Registration error: $e'); // Log the error for debugging
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> logout() async {
    await firebase_auth.FirebaseAuth.instance.signOut();
    _user = null;
    notifyListeners();
    await _clearTempProfile();
  }

  Future<void> _syncTempProfileToPermanent(String uid) async {
    final tempProfile = await _loadTempProfile();
    if (tempProfile.isNotEmpty) {
      await _savePermanentProfile(uid, tempProfile);
      await _clearTempProfile();
    }
  }

  Future<void> _savePermanentProfile(String uid, Map<String, dynamic> profile) async {
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
        body: jsonEncode(profile),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Failed to save permanent profile: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to save profile: ${response.statusCode}');
      } else {
        print('Profile saved successfully: ${response.body}');
      }
    } catch (e) {
      print('Error saving permanent profile: $e');
      rethrow; // Propagate the error for handling upstream
    }
  }

  Future<Map<String, dynamic>> _loadTempProfile() async {
    return await SharedPreferencesService.loadTempProfile();
  }

  Future<void> _saveTempProfile(Map<String, dynamic> profile) async {
    await SharedPreferencesService.saveTempProfile(profile);
  }

  Future<void> _clearTempProfile() async {
    await SharedPreferencesService.clearTempProfile();
  }

  void syncAnswersWithProfile(AnswersProvider answersProvider) {
    final answers = answersProvider.answers;
    _saveTempProfile(answers);
    if (_user != null) {
      _syncTempProfileToPermanent(_user!.uid);
    }
  }
}