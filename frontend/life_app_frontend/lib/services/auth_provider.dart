import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // For temporary storage
import 'package:life_app_frontend/services/answers_provider.dart'; // For syncing question answers

class AuthProvider with ChangeNotifier {
  firebase_auth.User? _user;
  final String _tempProfileKey = 'tempProfile'; // Key for shared_preferences

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

  Future<void> login(String email, String password) async {
    try {
      final userCredential = await firebase_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      notifyListeners();
      if (_user != null) {
        await _syncTempProfileToPermanent(_user!.uid);
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> register(String email, String password, Map<String, dynamic> tempProfile) async {
    try {
      final userCredential = await firebase_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      notifyListeners();
      if (_user != null) {
        await _savePermanentProfile(_user!.uid, tempProfile);
      }
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> logout() async {
    await firebase_auth.FirebaseAuth.instance.signOut();
    _user = null;
    notifyListeners();
    await _clearTempProfile(); // Clear temporary data on logout
  }

  Future<void> _syncTempProfileToPermanent(String uid) async {
    final tempProfile = await _loadTempProfile();
    if (tempProfile.isNotEmpty) {
      await _savePermanentProfile(uid, tempProfile);
      await _clearTempProfile(); // Clear after syncing
    }
  }

  Future<void> _savePermanentProfile(String uid, Map<String, dynamic> profile) async {
    final idToken = await _user?.getIdToken();
    if (idToken != null) {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/users/$uid/profile'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(profile),
      );
      if (response.statusCode != 200) {
        print('Failed to save permanent profile: ${response.statusCode}');
      }
    }
  }

  Future<Map<String, dynamic>> _loadTempProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final tempProfileJson = prefs.getString(_tempProfileKey);
    if (tempProfileJson != null) {
      return jsonDecode(tempProfileJson) as Map<String, dynamic>;
    }
    return {};
  }

  Future<void> _saveTempProfile(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tempProfileKey, jsonEncode(profile));
  }

  Future<void> _clearTempProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tempProfileKey);
  }

  // Helper to sync with AnswersProvider for question answers
  void syncAnswersWithProfile(AnswersProvider answersProvider) {
    final answers = answersProvider.answers;
    _saveTempProfile(answers); // Save answers as temp profile
    if (_user != null) {
      _syncTempProfileToPermanent(_user!.uid); // Sync to permanent if logged in
    }
  }
}