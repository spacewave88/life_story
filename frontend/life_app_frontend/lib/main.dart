import 'package:flutter/material.dart';
import 'package:life_app_frontend/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:life_app_frontend/screens/registration_screen.dart';
import 'package:life_app_frontend/screens/login_screen.dart';
import 'package:life_app_frontend/screens/home_page.dart';
import 'package:provider/provider.dart';
import 'package:life_app_frontend/services/auth_provider.dart' as auth_service;
import 'package:life_app_frontend/themes/theme.dart';
import 'package:life_app_frontend/screens/ancestors_screen.dart';
import 'package:life_app_frontend/screens/childhood_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('YES Firebase initialized');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => auth_service.AuthProvider(),
      child: MaterialApp(
        title: 'Lifestory',
        theme: getAppTheme(),
        debugShowCheckedModeBanner: false,  // Remove the debug banner
        home: HomePage(title: 'Lifestory'),
        routes: {
          '/register': (context) => RegistrationScreen(),
          '/login': (context) => LoginScreen(),
          '/ancestors': (context) => const AncestorsScreen(),
          '/childhood': (context) => const ChildhoodScreen(),
          // Add more routes as needed
        },
      ),
    );
  }
}