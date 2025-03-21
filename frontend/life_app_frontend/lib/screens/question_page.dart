import 'package:flutter/material.dart';
import 'package:life_app_frontend/widgets/responsive_nav_bar_page.dart';
import 'package:provider/provider.dart';
import 'package:life_app_frontend/services/auth_provider.dart';
import 'package:life_app_frontend/services/answers_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:life_app_frontend/services/shared_preferences.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({super.key});

  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'What decade were you born?',
      'options': ['1920s or 1930s', '1940s or 1950s', '1960s or 1970s', '1980s or 1990s', '2000s or later']
    },
    {
      'question': 'Do you have children?',
      'options': ['Yes', 'No', 'Maybe in the future', 'Prefer not to answer']
    },
    {
      'question': 'How many different cities have you lived in your life?',
      'options': ['I have lived in the same place my whole life', '2', '3', '4+']
    },
    {
      'question': 'Highest degree of education?',
      'options': ['High School', 'Some College', 'University', 'Graduate School +', 'Prefer not to answer']
    },
    {
      'question': 'Do you have any siblings?',
      'options': ['No', 'Yes, brother(s)', 'Yes, sister(s)', 'Yes, brother(s) and sister(s)', 'Prefer not to answer']
    },
     {
      'question': 'Were you the oldest, middle or youngest child?',
      'options': ['Oldest Child', 'Middle Child', 'Youngest Child', 'Prefer not to answer']
    },
      {
      'question': 'Are you currently in any pain?',
      'options': ['No', 'Yes, a little', 'Yes, quite a bit', 'Prefer not to answer']
    },
     {
      'question': 'Which best describes where you were born?',
      'options': ['Countryside', 'Suburb', 'City', 'Other']
    },
     {
      'question': 'Have you ever had a pet?',
      'options': ['No', 'Yes, and I have one now', 'Yes, in the past', 'Prefer not to answer']
    },
     {
      'question': 'Do you believe in a higher power?',
      'options': ['Yes, I believe in God', 'Yes, I believe in a higher power', 'Im not sure', 'No, I am atheist', 'Prefer not to answer']
    },
     {
      'question': 'Have you lived overseas?',
      'options': ['No', 'Yes', 'Prefer not to answer']
    },
     {
      'question': 'How did you hear about us?',
      'options': ['Family Member', 'Friend', 'Social Media', 'Google search']
    },
  ];

  int currentQuestionIndex = 0;
  String? selectedAnswer;
  bool canContinue = false;

  void _selectAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      canContinue = true;
    });
    final answersProvider = Provider.of<AnswersProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    answersProvider.updateAnswer(questions[currentQuestionIndex]['question'] as String, answer);
    authProvider.syncAnswersWithProfile(answersProvider); // Save answers to temp profile
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1 && canContinue) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
        canContinue = false;
      });
    } else if (currentQuestionIndex == questions.length - 1 && canContinue) {
      _saveAnswersAndNavigate();
    }
  }

  Future<void> _saveAnswersAndNavigate() async {
    final answersProvider = Provider.of<AnswersProvider>(context, listen: false);
    final answers = answersProvider.answers;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      final idToken = await authProvider.user?.getIdToken();
      if (idToken != null) {
        final response = await http.post(
          Uri.parse('http://localhost:3000/api/users/${authProvider.user!.uid}/answers'),
          headers: {
            'Authorization': 'Bearer $idToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(answers),
        );
        if (response.statusCode != 200) {
          print('Failed to save answers: ${response.statusCode}');
        }
      }
    } else {
      print('Saving answers temporarily: $answers');
    }

    // Mark questions as completed
    await SharedPreferencesService.setQuestionsCompleted(true);

    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  void _navigateToLogin() {
    Navigator.pushNamed(context, '/login');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalQuestions = questions.length;
    final progress = (currentQuestionIndex + (canContinue ? 1 : 0)) / totalQuestions;

    return ResponsiveNavBarPage(
      scaffoldKey: _scaffoldKey,
      title: 'Your Story Questions',
      scrollController: _scrollController,
      navbarActions: [
        TextButton(
          onPressed: _navigateToLogin,
          child: Text('I Already Have an Account', style: TextStyle(color: Colors.white)),
        ),
      ],
      body: Builder(
        builder: (context) {
          return Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  color: Colors.green,
                  minHeight: 10,
                ),
                const SizedBox(height: 20),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey,
                        child: Text('?', style: TextStyle(color: Colors.white, fontSize: 20)),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'How much do you know about your story?',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Text(
                        questions[currentQuestionIndex]['question'] as String,
                        style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ...(questions[currentQuestionIndex]['options'] as List<String>).map((option) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: GestureDetector(
                            onTap: () => _selectAnswer(option),
                            child: Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: selectedAnswer == option ? Colors.green : Colors.blue),
                                borderRadius: BorderRadius.circular(8),
                                color: selectedAnswer == option ? Colors.green[100] : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    selectedAnswer == option ? Icons.check_circle : Icons.circle,
                                    color: selectedAnswer == option ? Colors.green : Colors.blue,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    option,
                                    style: TextStyle(color: Colors.black, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: canContinue ? _nextQuestion : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canContinue ? Colors.green : Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      currentQuestionIndex < questions.length - 1 ? 'Continue' : 'Finish',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}