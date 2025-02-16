import 'package:flutter/material.dart';

class ChildhoodScreen extends StatelessWidget {
  const ChildhoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Childhood'),
      ),
      body: const Center(
        child: Text('Memories of the past'),
      ),
    );
  }
}