import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:life_app_frontend/widgets/responsive_nav_bar_page.dart';
import 'package:provider/provider.dart';
import 'package:life_app_frontend/services/auth_provider.dart';

class LaunchPage extends StatefulWidget {
  const LaunchPage({super.key});

  @override
  _LaunchPageState createState() => _LaunchPageState();
}

class _LaunchPageState extends State<LaunchPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final ScrollController _scrollController = ScrollController();
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
    final theme = Theme.of(context);
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    // Handle authenticated user redirect
    if (authProvider.user != null && ModalRoute.of(context)?.isCurrent == true && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      });
    }

    return ResponsiveNavBarPage(
      scaffoldKey: _scaffoldKey,
      title: 'Lifestory',
      scrollController: _scrollController,
      navbarActions: _isScrolled
          ? [
              TextButton(
                onPressed: _navigateToLogin,
                child: Text(
                  'I Already Have an Account',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _navigateToQuestionPage,
                child: Text(
                  'Get Started',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ]
          : null,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // Hero Section
            if (!_isScrolled)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 80 : 120,
                  horizontal: isSmallScreen ? 16 : 32,
                ),
                color: theme.colorScheme.surface.withValues(alpha: 0.9),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'The Free, Fun, and Meaningful Way to Tell Your Story!',
                        style: GoogleFonts.dancingScript(
                          textStyle: theme.textTheme.displayLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: _navigateToQuestionPage,
                        child: const Text('Get Started'),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _navigateToLogin,
                        child: Text(
                          'I Already Have an Account',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Content Sections
            _buildSection(
              context,
              title: 'Discover Your Story',
              description:
                  'Learn how Lifestory helps you capture and share your life’s journey with ease. Create a personal timeline with photos, stories, and memories.',
              imageUrl: 'https://via.placeholder.com/300x200.png?text=Discover+Your+Story',
              isSmallScreen: isSmallScreen,
              reverse: false,
            ),
            _buildSection(
              context,
              title: 'Watch Our Journey',
              description:
                  'Explore a short video showcasing how users love telling their stories. See Lifestory in action and get inspired.',
              imageUrl: 'https://via.placeholder.com/300x200.png?text=Watch+Our+Journey',
              isSmallScreen: isSmallScreen,
              reverse: true,
            ),
            _buildSection(
              context,
              title: 'Why Choose Lifestory?',
              description:
                  'Discover the benefits of preserving your memories with us. Secure, easy-to-use, and designed to bring your stories to life.',
              imageUrl: 'https://via.placeholder.com/300x200.png?text=Why+Lifestory',
              isSmallScreen: isSmallScreen,
              reverse: false,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String description,
    required String imageUrl,
    required bool isSmallScreen,
    required bool reverse,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200), // Web-friendly width
        child: Card(
          elevation: theme.cardTheme.elevation,
          shape: theme.cardTheme.shape,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: isSmallScreen
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        imageUrl,
                        height: isSmallScreen ? 150 : 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 16),
                      Text(title, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 12),
                      Text(
                        description,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.left,
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: reverse
                        ? [
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(title, style: theme.textTheme.titleLarge),
                                    const SizedBox(height: 12),
                                    Text(
                                      description,
                                      style: theme.textTheme.bodyMedium,
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Image.network(
                                imageUrl,
                                height: 250,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ]
                        : [
                            Expanded(
                              flex: 1,
                              child: Image.network(
                                imageUrl,
                                height: 250,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(title, style: theme.textTheme.titleLarge),
                                    const SizedBox(height: 12),
                                    Text(
                                      description,
                                      style: theme.textTheme.bodyMedium,
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
      ),
    );
  }
}