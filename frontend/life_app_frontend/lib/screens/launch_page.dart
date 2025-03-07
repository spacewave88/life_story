import 'package:flutter/material.dart';
import 'package:life_app_frontend/widgets/responsive_nav_bar_page.dart';
import 'package:provider/provider.dart';
import 'package:life_app_frontend/services/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class LaunchPage extends StatefulWidget {
  const LaunchPage({super.key});

  @override
  _LaunchPageState createState() => _LaunchPageState();
}

class _LaunchPageState extends State<LaunchPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final ScrollController _scrollController = ScrollController(); // Initialize lazily
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _isScrolled = _scrollController.offset > 100;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToQuestionPage() {
    Navigator.pushNamed(context, '/question');
  }

  void _navigateToLogin() {
    Navigator.pushNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Avoid redirecting if not the initial load
    if (authProvider.user != null && ModalRoute.of(context)?.isCurrent == true && !mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      });
    }

    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return ResponsiveNavBarPage(
      scaffoldKey: _scaffoldKey,
      title: 'Lifestory',
      scrollController: _scrollController,
      navbarActions: _isScrolled
          ? [
              TextButton(
                onPressed: _navigateToLogin,
                child: Text('I Already Have an Account', style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                onPressed: _navigateToQuestionPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Get Started', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ]
          : null,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isScrolled)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 100.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'The Free, Fun, and Meaningful Way to Tell Your Story!',
                        style: GoogleFonts.dancingScript(
                          textStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: _navigateToQuestionPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('Get Started', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _navigateToLogin,
                        child: Text('I Already Have an Account', style: TextStyle(color: Colors.blue, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 1, child: FlutterLogo(size: isSmallScreen ? 100 : 200)),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Discover Your Story', style: Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 16),
                            Text(
                              'Learn how Lifestory helps you capture and share your life’s journey with ease. Placeholder text for an engaging description.',
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Watch Our Journey', style: Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 16),
                            Text(
                              'Explore a short video showcasing how users love telling their stories. Placeholder text for video description.',
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(flex: 1, child: FlutterLogo(size: isSmallScreen ? 100 : 200)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 1, child: FlutterLogo(size: isSmallScreen ? 100 : 200)),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Why Choose Lifestory?', style: Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 16),
                            Text(
                              'Discover the benefits of preserving your memories with us. Placeholder text for more details.',
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}