import 'package:chatapp/authservice.dart';
import 'package:flutter/material.dart';

// Create Account screen
// Imported and shown on the welcome screen when the create account button is pressed
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen(this.authService, {super.key});

  final AuthService authService;

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  // Form state key
  final _formKey = GlobalKey<FormState>();

  // Hardcoded login details
  final String adminUsername = 'admin';
  final String adminPassword = 'admin';
  final String viewerUsername = 'viewer';
  final String viewerPassword = 'viewer';

  // Text field controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Track password visibility for the "show password" toggle
  bool _isPasswordVisible = false;

  void _submitForm() async {
    String emailAddress = _usernameController.text;
    String password = _passwordController.text;

    await widget.authService.createAccount(emailAddress, password);

    print('are we logged in?');
    print(widget.authService.isLoggedIn());
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        spacing: 24.0,
        children: [
          // Username field
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
          ),

          // Submit button
          ElevatedButton(
            onPressed: _submitForm,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('Create Account')],
            ),
          ),
        ],
      ),
    );
  }
}
