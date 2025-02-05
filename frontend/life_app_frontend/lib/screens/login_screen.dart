import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final email = _emailController.text;
                final password = _passwordController.text;

                try {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  await authProvider.login(email, password);
                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                } catch (e) {
                  print('Login failed: $e');
                }
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}