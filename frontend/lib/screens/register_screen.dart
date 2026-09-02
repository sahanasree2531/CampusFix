import 'package:flutter/material.dart';

import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String role = 'student';

  bool loading = false;
  bool obscurePassword = true;

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    // -----------------------------
    // VALIDATION
    // -----------------------------

    if (name.isEmpty) {
      showMessage('Please enter your name');
      return;
    }

    if (email.isEmpty) {
      showMessage('Please enter your email');
      return;
    }

    if (!email.contains('@')) {
      showMessage('Please enter a valid email address');
      return;
    }

    if (password.isEmpty) {
      showMessage('Please enter a password');
      return;
    }

    if (password.length < 6) {
      showMessage('Password must contain at least 6 characters');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      // -----------------------------
      // CALL BACKEND REGISTER API
      // -----------------------------

      await ApiService.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );

      if (!mounted) return;

      // -----------------------------
      // SUCCESS MESSAGE
      // -----------------------------

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$role account created successfully!',
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Give the user time to see the message.
      await Future.delayed(
        const Duration(milliseconds: 800),
      );

      if (!mounted) return;

      // -----------------------------
      // RETURN TO LOGIN SCREEN
      // -----------------------------

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      showMessage(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Column(
            children: [

              // -----------------------------
              // ICON
              // -----------------------------

              const Icon(
                Icons.person_add,
                size: 70,
              ),

              const SizedBox(height: 20),

              // -----------------------------
              // TITLE
              // -----------------------------

              const Text(
                'Join CampusFix',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Create your CampusFix account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 30),

              // -----------------------------
              // NAME
              // -----------------------------

              TextField(
                controller: nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // -----------------------------
              // EMAIL
              // -----------------------------

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // -----------------------------
              // PASSWORD
              // -----------------------------

              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // -----------------------------
              // ROLE
              // -----------------------------

              DropdownButtonFormField<String>(
                initialValue: role,

                decoration: const InputDecoration(
                  labelText: 'Account Type',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),

                items: const [

                  DropdownMenuItem(
                    value: 'student',
                    child: Text('Student'),
                  ),

                  DropdownMenuItem(
                    value: 'maintenance',
                    child: Text('Maintenance Staff'),
                  ),

                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('Admin'),
                  ),

                ],

                onChanged: loading
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            role = value;
                          });
                        }
                      },
              ),

              const SizedBox(height: 30),

              // -----------------------------
              // REGISTER BUTTON
              // -----------------------------

              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton(
                  onPressed: loading ? null : register,

                  child: loading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(),
                        )
                      : const Text(
                          'CREATE ACCOUNT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 15),

              // -----------------------------
              // BACK TO LOGIN
              // -----------------------------

              TextButton(
                onPressed: loading
                    ? null
                    : () {
                        Navigator.pop(context);
                      },

                child: const Text(
                  'Already have an account? Login',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }
}