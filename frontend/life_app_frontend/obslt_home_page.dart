import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Add search functionality here
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Add notifications functionality here
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to the Home Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  TextLink(
                    text: 'The Beginning',
                    route: '/the-beginning',
                    endPoint: const Offset(0, 50),
                  ),
                  TextLink(
                    text: 'To those who came before you',
                    route: '/ancestors',
                    startPoint: const Offset(0, 50),
                    endPoint: const Offset(50, 100),
                  ),
                  TextLink(
                    text: 'Childhood',
                    route: '/childhood',
                    startPoint: const Offset(50, 100),
                    endPoint: const Offset(25, 150),
                  ),
                  // Add more TextLink widgets as needed, adjusting startPoint and endPoint to create the desired cascade effect
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Add functionality for button 1
                  },
                  child: Text('Button 1'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Add functionality for button 2
                  },
                  child: Text('Button 2'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TextLink extends StatelessWidget {
  final String text;
  final String route;
  final Offset startPoint;
  final Offset endPoint;

  const TextLink({
    required this.text,
    required this.route,
    this.startPoint = Offset.zero,
    required this.endPoint,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        child: Text(
          text,
          style: TextStyle(fontSize: 18, color: Colors.blue),
        ),
      ),
    );
  }
}