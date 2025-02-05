// lib/services/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class AuthProvider with ChangeNotifier {
  firebase_auth.User? _user;

  firebase_auth.User? get user => _user;

  AuthProvider() {
    _user = firebase_auth.FirebaseAuth.instance.currentUser;
    firebase_auth.FirebaseAuth.instance.authStateChanges().listen((firebase_auth.User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> login(String email, String password) async {
    await firebase_auth.FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    _user = firebase_auth.FirebaseAuth.instance.currentUser;
    notifyListeners();
  }

  Future<void> logout() async {
    await firebase_auth.FirebaseAuth.instance.signOut();
    _user = null;
    notifyListeners();
  }
}