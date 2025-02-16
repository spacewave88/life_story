import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import 'package:life_app_frontend/widgets/responsive_nav_bar_page.dart'; // Import the ResponsiveNavBarPage

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return ResponsiveNavBarPage(
      scaffoldKey: GlobalKey<ScaffoldState>(),
      title: 'Login',
      scrollController: ScrollController(),
      body: Center(
        child: isSmallScreen
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Logo(),
                  _FormContent(
                    formKey: _formKey,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    isPasswordVisible: _isPasswordVisible,
                    rememberMe: _rememberMe,
                    onPasswordVisibilityChanged: (value) {
                      setState(() {
                        _isPasswordVisible = value;
                      });
                    },
                    onRememberMeChanged: (value) {
                      setState(() {
                        _rememberMe = value;
                      });
                    },
                    onSubmit: _login,
                  ),
                ],
              )
            : Container(
                padding: const EdgeInsets.all(32.0),
                constraints: const BoxConstraints(maxWidth: 800),
                child: Row(
                  children: [
                    Expanded(child: _Logo()),
                    Expanded(
                      child: Center(
                        child: _FormContent(
                          formKey: _formKey,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          isPasswordVisible: _isPasswordVisible,
                          rememberMe: _rememberMe,
                          onPasswordVisibilityChanged: (value) {
                            setState(() {
                              _isPasswordVisible = value;
                            });
                          },
                          onRememberMeChanged: (value) {
                            setState(() {
                              _rememberMe = value;
                            });
                          },
                          onSubmit: _login,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      hideAuthButtons: true, // Hide the auth buttons on the login screen
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text;
      final password = _passwordController.text;

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.login(email, password);
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } catch (e) {
        print('Login failed: $e');
      }
    }
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FlutterLogo(size: isSmallScreen ? 100 : 200),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Welcome to Your Story!",
            textAlign: TextAlign.center,
            style: isSmallScreen
                ? Theme.of(context).textTheme.headlineSmall
                : Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: Colors.black),
          ),
        )
      ],
    );
  }
}

class _FormContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isPasswordVisible;
  final bool rememberMe;
  final ValueChanged<bool> onPasswordVisibilityChanged;
  final ValueChanged<bool> onRememberMeChanged;
  final VoidCallback onSubmit;

  const _FormContent({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isPasswordVisible,
    required this.rememberMe,
    required this.onPasswordVisibilityChanged,
    required this.onRememberMeChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('New? Create a Profile here:'),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text('Sign Up'),
                ),
              ],
            ),
            _gap(),
            TextFormField(
              controller: emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }

                bool emailValid = RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(value);
                if (!emailValid) {
                  return 'Please enter a valid email';
                }

                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            _gap(),
            TextFormField(
              controller: passwordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }

                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
              obscureText: !isPasswordVisible,
              decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      onPasswordVisibilityChanged(!isPasswordVisible);
                    },
                  )),
            ),
            _gap(),
            CheckboxListTile(
              value: rememberMe,
              onChanged: (value) {
                if (value == null) return;
                onRememberMeChanged(value);
              },
              title: const Text('Remember me'),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              contentPadding: const EdgeInsets.all(0),
            ),
            _gap(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Sign in',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                onPressed: onSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 16);
}