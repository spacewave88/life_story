import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:life_app_frontend/services/auth_provider.dart';
import 'package:life_app_frontend/services/story_provider.dart';

class StoryPage extends StatefulWidget {
  const StoryPage({Key? key}) : super(key: key);

  @override
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  String _selectedCategory = 'childhood';
  final List<String> _categories = ['childhood', 'university', 'parenthood'];
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        Provider.of<StoryProvider>(context, listen: false).fetchStory(authProvider.user!.uid, authProvider.user!.getIdToken());
      }
    });
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final storyProvider = Provider.of<StoryProvider>(context);

    if (authProvider.user == null) {
      return Scaffold(body: Center(child: Text('Please log in to view your story.')));
    }

    return Scaffold(
      appBar: AppBar(title: Text('My Life Story')),
      body: Column(
        children: [
          DropdownButton<String>(
            value: _selectedCategory,
            onChanged: (value) => setState(() => _selectedCategory = value!),
            items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat.capitalize()))).toList(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: storyProvider.segments.where((s) => s['category'] == _selectedCategory).length,
              itemBuilder: (context, index) {
                final segment = storyProvider.segments.where((s) => s['category'] == _selectedCategory).toList()[index];
                _controllers[segment['_id']] ??= TextEditingController(text: segment['processedContent']);
                return ListTile(
                  title: TextField(
                    controller: _controllers[segment['_id']],
                    maxLines: null,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                  subtitle: Text('Order: ${segment['order']}'),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final idToken = await authProvider.user!.getIdToken();
              if (idToken != null) {
                await storyProvider.saveStory(authProvider.user!.uid, idToken, _controllers);
              }
            },
            child: Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}