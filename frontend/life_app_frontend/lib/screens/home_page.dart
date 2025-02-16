import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:life_app_frontend/widgets/responsive_nav_bar_page.dart'; // Import the ResponsiveNavBarPage
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:life_app_frontend/services/auth_provider.dart'; // Corrected import path

class HomePage extends StatefulWidget {
  final String title;

  HomePage({Key? key, required this.title}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    try {
      await firebase_auth.FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false, arguments: 'You have successfully logged out');
    } catch (e) {
      // Handle logout error
      print(e);
    }
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
                    'Welcome, ${currentUser.displayName}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
}