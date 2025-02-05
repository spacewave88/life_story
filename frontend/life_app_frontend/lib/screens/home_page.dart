import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  String logoutMessage = '';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final firebase_auth.User? currentUser = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF9CAF88),
        title: Text(widget.title),
        actions: [
          if (currentUser != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await _authService.signOut();
                authProvider.logout();
                setState(() {
                  logoutMessage = 'You have successfully logged out';
                });
              },
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              currentUser != null 
                ? 'Welcome, ${currentUser.email}!' 
                : 'Welcome to Life App',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            if (currentUser == null) ...[
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('Login'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('Register'),
              ),
            ],
            if (logoutMessage.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                logoutMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ],
          ],
        ),
      ),
    );
  }
}