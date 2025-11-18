import 'package:flutter/material.dart';
import 'package:chatapp/authservice.dart';
import 'package:chatapp/models/user_entry.dart';
import 'package:chatapp/models/user_database.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen(this.authService, {super.key});

  final AuthService authService;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // TODO: change password
  // TODO: change email

  UserDatabase userDB = UserDatabase();

  UserEntry? userInfo;
  late String email;

  @override
  void initState() {
    super.initState();

    email = widget.authService.getEmail();

    userDB.getUserEntryFromEmail(email).then((result) {
      print("result: $result");
      setState(() {
        if (result != null) {
          userInfo = result;
        }
      });
    });
  }

  void _logout() {
    widget.authService.logout();
  }

  @override
  Widget build(BuildContext context) {
    //String userInfoString = userInfo!.toFirestore().toString();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(64.0),
        child: Column(
          children: [
            /*
            Text('Welcome! Your email is $email'),
            SizedBox(height: 20),
            Text('Other profile information:'),
            SizedBox(height: 20),
            (userInfoString != null) ? Text(user2) : Container(),
            (userInfoString != null) ? SizedBox(height: 20) : Container(),
            */
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
    );
  }
}
