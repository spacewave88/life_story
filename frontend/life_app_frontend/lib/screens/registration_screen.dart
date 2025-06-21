
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:life_app_frontend/widgets/responsive_nav_bar_page.dart';
import 'package:provider/provider.dart';
import 'package:life_app_frontend/services/auth_provider.dart' as CustomAuth;
import 'package:life_app_frontend/services/answers_provider.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        final authProvider = Provider.of<CustomAuth.AuthProvider>(context, listen: false);
        await authProvider.register(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _firstNameController.text.trim(),
          _lastNameController.text.trim(),
          _dobController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful')),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
          arguments: 'Registration Successful',
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return ResponsiveNavBarPage(
      scaffoldKey: GlobalKey<ScaffoldState>(),
      title: 'Register',
      scrollController: ScrollController(),
      hideAuthButtons: true,
      body: Center(
        child: isSmallScreen
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Logo(),
                  _RegistrationFormContent(
                    formKey: _formKey,
                    firstNameController: _firstNameController,
                    lastNameController: _lastNameController,
                    dobController: _dobController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    isPasswordVisible: _passwordVisible,
                    onPasswordVisibilityChanged: (value) {
                      setState(() {
                        _passwordVisible = value;
                      });
                    },
                    onSubmit: _registerUser,
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
                        child: _RegistrationFormContent(
                          formKey: _formKey,
                          firstNameController: _firstNameController,
                          lastNameController: _lastNameController,
                          dobController: _dobController,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          isPasswordVisible: _passwordVisible,
                          onPasswordVisibilityChanged: (value) {
                            setState(() {
                              _passwordVisible = value;
                            });
                          },
                          onSubmit: _registerUser,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
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

class _RegistrationFormContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController dobController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isPasswordVisible;
  final ValueChanged<bool> onPasswordVisibilityChanged;
  final VoidCallback onSubmit;

  const _RegistrationFormContent({
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.dobController,
    required this.emailController,
    required this.passwordController,
    required this.isPasswordVisible,
    required this.onPasswordVisibilityChanged,
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
          children: [
            TextFormField(
              controller: firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
                hintText: 'Enter your first name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your first name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                hintText: 'Enter your last name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your last name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: dobController,
              decoration: const InputDecoration(
                labelText: 'Date of Birth',
                hintText: 'MM/DD/YYYY',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your date of birth';
                }
                // Basic date format validation
                final datePattern = RegExp(r'^\d{2}/\d{2}/\d{4}$');
                if (!datePattern.hasMatch(value)) {
                  return 'Please use MM/DD/YYYY format';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                final emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailPattern.hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    onPasswordVisibilityChanged(!isPasswordVisible);
                  },
                ),
              ),
              obscureText: !isPasswordVisible,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
                final hasNumber = RegExp(r'\d').hasMatch(value);
                final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
                final hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
                final hasLowercase = RegExp(r'[a-z]').hasMatch(value);
                if (!hasLetter || !hasNumber || !hasSpecial || !hasUppercase || !hasLowercase) {
                  return 'Password must include letters, numbers, special characters, and both uppercase and lowercase';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            const Text(
              'At least 8 characters, mix of letters and numbers,\nAt least 1 special character, and at least 1 lowercase and 1 uppercase letter',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSubmit,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                text: "By submitting, I accept YourStory's ",
                style: const TextStyle(fontSize: 10, color: Colors.black),
                children: <TextSpan>[
                  TextSpan(
                    text: 'terms of use',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Handle hyperlink tap (e.g., open terms URL)
                      },
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}