import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:life_app_frontend/widgets/responsive_nav_bar_page.dart'; // Import the ResponsiveNavBarPage
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:life_app_frontend/services/auth_provider.dart'; 
import 'package:life_app_frontend/services/auth_service.dart'; // Import AuthService
import 'package:http/http.dart' as http; // Import http package
import 'dart:convert'; // Import for jsonDecode

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({Key? key, required this.title}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final AuthService _authService = AuthService();
  String? _firstName; // Variable to store fetched firstName

  @override
  void initState() {
    super.initState();
    _fetchUserProfile(); // Fetch user profile on initialization
  }

  Future<void> _fetchUserProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final firebase_auth.User? currentUser = authProvider.user;
    if (currentUser != null) {
      try {
        // Fetch user profile from backend
        await _authService.getUserProfile(currentUser.uid);
        final response = await http.get(
          Uri.parse('http://localhost:3000/api/users/${currentUser.uid}'),
          headers: {
            'Authorization': 'Bearer ${await currentUser.getIdToken()}',
            'Content-Type': 'application/json',
          },
        );
        if (response.statusCode == 200) {
          final userData = jsonDecode(response.body);
          setState(() {
            _firstName = userData['user']['firstName']; // Update with fetched firstName
          });
        } else {
          print('Failed to fetch user profile: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching user profile: $e');
      }
    }
  }

  Future<void> _logout() async {
    try {
      await firebase_auth.FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false, arguments: 'You have successfully logged out');
    } catch (e) {
      print('Logout error: $e');
    }
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final firebase_auth.User? currentUser = authProvider.user;
    final String? logoutMessage = ModalRoute.of(context)?.settings.arguments as String?;

    return ResponsiveNavBarPage(
      scaffoldKey: _scaffoldKey,
      title: widget.title,
      scrollController: _scrollController,
      onLogout: currentUser != null ? _logout : null,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (logoutMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  logoutMessage,
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
              ),
            currentUser == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Mement - Let your story persevere',
                        style: GoogleFonts.dancingScript(
                          textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Text('Log In'),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: Text('Register'),
                      ),
                    ],
                  )
                : Text(
                    'Welcome, ${_firstName ?? "User"}', // Use fetched firstName or fallback to "User"
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
          ],
        ),
      ),
    );
  }
}