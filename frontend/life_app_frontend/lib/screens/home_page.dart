import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:life_app_frontend/widgets/responsive_nav_bar_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:life_app_frontend/services/auth_provider.dart';
import 'package:life_app_frontend/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:life_app_frontend/services/chat_provider.dart';
import 'package:life_app_frontend/services/answers_provider.dart';

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
  final TextEditingController _chatController = TextEditingController();
  String? _firstName;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      final answers = Provider.of<AnswersProvider>(context, listen: false).answers;
      print('Answers: $answers'); // Debug log to verify answers
      chatProvider.setInitialPrompt(answers); // Initialize chat with answers
    });
  }

  Future<void> _fetchUserProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final firebase_auth.User? currentUser = authProvider.user;
    if (currentUser != null) {
      try {
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
          setState(() => _firstName = userData['user']['firstName']);
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/launch', // Changed to /launch
      (route) => false,
      arguments: 'You have successfully logged out',
    );
  } catch (e) {
    print('Logout error: $e');
  }
}

  Future<void> _sendChatMessage(ChatProvider chatProvider, AuthProvider authProvider) async {
    if (_chatController.text.isNotEmpty) {
      final idToken = authProvider.user != null ? await authProvider.user!.getIdToken() : '';
      await chatProvider.sendMessage(
        _chatController.text,
        Provider.of<AnswersProvider>(context, listen: false).answers,
        authProvider.user?.uid ?? 'guest',
        idToken ?? '',
      );
      _chatController.clear();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final firebase_auth.User? currentUser = authProvider.user;
    final String? logoutMessage = ModalRoute.of(context)?.settings.arguments as String?;

    return ResponsiveNavBarPage(
      scaffoldKey: _scaffoldKey,
      title: widget.title,
      scrollController: _scrollController,
      onLogout: currentUser != null ? _logout : null,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Center(
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
              Text(
                currentUser == null ? 'Welcome, Guest' : 'Welcome, ${_firstName ?? "User"}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              if (currentUser == null) ...[
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: Text('Log In'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: Text('Register'),
                ),
                const SizedBox(height: 20),
              ],
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/story'),
                child: Text('View My Story'),
              ),
              const SizedBox(height: 20),
              Container(
                height: MediaQuery.of(context).size.height * 0.4, // Dynamic height (40% of screen)
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: chatProvider.messages.isEmpty
                    ? Center(child: Text('No messages yet. Start chatting!'))
                    : ListView.builder(
                        controller: ScrollController(),
                        itemCount: chatProvider.messages.length,
                        itemBuilder: (context, index) {
                          final message = chatProvider.messages[index];
                          return ListTile(
                            title: Text(
                              message['content'],
                              style: TextStyle(
                                color: message['role'] == 'user' ? Colors.blue : Colors.black,
                              ),
                            ),
                            subtitle: Text(message['role']),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _chatController,
                        decoration: InputDecoration(
                          hintText: 'Share your story...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () => _sendChatMessage(chatProvider, authProvider),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
