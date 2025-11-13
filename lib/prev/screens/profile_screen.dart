import 'package:firebaseauth/authservice.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key, required this.emailAddress});

  final String emailAddress;

  final AuthService authService = AuthService();

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _logout() async {
    await widget.authService.logout();

    print('are we logged in?');
    print(widget.authService.isLoggedIn());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Screen')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(64.0),
          child: Column(
            children: [
              Text('Welcome! Your email is ${widget.emailAddress}'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _logout,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text('Log out')],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
