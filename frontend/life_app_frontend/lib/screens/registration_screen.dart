import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLandlord = false;
  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        await _authService.createUserProfile();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User registered successfully')),
        );
        // Optionally, navigate to a new screen or update UI to reflect registered in state
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register: ${e.message}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Welcome to Life App', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      // Navigate to login screen
                    },
                    child: Text('Sign in', style: TextStyle(color: Colors.black)),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('New account', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8.0),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Enter email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              Text('Password', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8.0),
              TextFormField(
                controller: _passwordController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  hintText: 'Create password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  if (!value.contains(RegExp(r'[A-Z]')) || !value.contains(RegExp(r'[a-z]'))) {
                    return 'Password must contain upper and lower case letters';
                  }
                  if (!value.contains(RegExp(r'[0-9]'))) {
                    return 'Password must contain a number';
                  }
                  if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                    return 'Password must contain a special character';
                  }
                  return null;
                },
              ),
              SizedBox(height: 8.0),
              Text(
                'At least 8 characters\nMix of letters and numbers\nAt least 1 special character\nAt least 1 lowercase letter and 1 uppercase letter',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Checkbox(
                    value: _isLandlord,
                    onChanged: (bool? value) {
                      setState(() {
                        _isLandlord = value!;
                      });
                    },
                  ),
                  Text('I am a landlord or industry professional'),
                ],
              ),
              SizedBox(height: 16.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: _registerUser,
                  child: Text('Submit', style: TextStyle(color: Colors.black)),
                ),
              ),
              SizedBox(height: 16.0),
              Center(
                child: Text(
                  'By submitting, I accept Life App\'s terms of use.',
                  style: TextStyle(color: Colors.blue, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}