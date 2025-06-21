import 'package:flutter/material.dart';
import 'package:life_app_frontend/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:life_app_frontend/screens/registration_screen.dart';
import 'package:life_app_frontend/screens/login_screen.dart';
import 'package:life_app_frontend/screens/launch_page.dart';
import 'package:life_app_frontend/screens/question_page.dart';
import 'package:life_app_frontend/screens/home_page.dart';
import 'package:provider/provider.dart';
import 'package:life_app_frontend/services/auth_provider.dart' as auth_service;
import 'package:life_app_frontend/services/answers_provider.dart';
import 'package:life_app_frontend/services/chat_provider.dart';
import 'package:life_app_frontend/themes/theme.dart';
import 'package:life_app_frontend/screens/ancestors_screen.dart';
import 'package:life_app_frontend/screens/childhood_screen.dart';
import 'package:life_app_frontend/services/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:life_app_frontend/screens/story_page.dart';
import 'package:life_app_frontend/services/story_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: '.env'); // Load .env from /life_app/frontend/
  print('YES Firebase initialized');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => auth_service.AuthProvider()),
        ChangeNotifierProvider(create: (_) => AnswersProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()), // Added ChatProvider
        ChangeNotifierProvider(create: (_) => StoryProvider()),
      ],
      child: MaterialApp(
        title: 'Lifestory',
        theme: getAppTheme().copyWith(
          scaffoldBackgroundColor: Colors.white,
        ),
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        routes: {
          '/register': (context) => RegistrationScreen(),
          '/login': (context) => LoginScreen(),
          '/launch': (context) => const LaunchPage(),
          '/question': (context) => const QuestionPage(),
          '/home': (context) => HomePage(title: 'Lifestory'),
          '/ancestors': (context) => const AncestorsScreen(),
          '/childhood': (context) => const ChildhoodScreen(),
          '/story': (context) => const StoryPage(),
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    final authProvider = Provider.of<auth_service.AuthProvider>(context, listen: false);
    await Future.delayed(Duration(seconds: 1)); // Ensure auth state is ready
    print('Auth state checked: user = ${authProvider.user?.uid ?? "null"}');

    // Check if questions are completed
    final bool questionsCompleted = await SharedPreferencesService.areQuestionsCompleted();

    // Guard against unmounted state before navigation
    if (!mounted) return;

    // Redirect logic
    if (authProvider.user != null || questionsCompleted) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/launch');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  void dispose() {
    // Cancel any pending operations if needed (optional)
    super.dispose();
  }
}