import 'package:chatapp/authservice.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/models/user_entry.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen(this.authService, {super.key});

  final AuthService authService;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _logout() {
    widget.authService.logout();
  }

  @override
  Widget build(BuildContext context) {
    String finalInfo = '';
    String finalEmail = '';

    int functionTest = widget.authService.getCurrentUserInfoTest();
    print('result of call to getCurrentUserInfoTest() was code $functionTest');

    UserEntry? userinfo_test = widget.authService.getCurrentUserInfo();
    if (userinfo_test != null) {
      UserEntry userinfo = userinfo_test;
      Map userinfo_map = userinfo.toMap();
      String userinfo_string = userinfo_map.toString();
      finalInfo = userinfo_string;
      print(userinfo_string);
    } else {
      print('error: user info was null');
    }

    finalEmail = widget.authService.getEmail();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile Screen')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(64.0),
          child: Column(
            children: [
              Text('Welcome! Your email is $finalEmail'),
              SizedBox(height: 20),
              Text('Other profile information:'),
              SizedBox(height: 20),
              Text(finalInfo),
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
