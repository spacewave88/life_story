import 'package:flutter/material.dart';

class AncestorsScreen extends StatelessWidget {
  const AncestorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ancestors'),
      ),
      body: const Center(
        child: Text('Honoring those who came before us'),
      ),
    );
  }
}