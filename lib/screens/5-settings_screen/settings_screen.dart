import 'package:flutter/material.dart';
import 'package:chatapp/authservice.dart';
import 'package:chatapp/models/user_entry.dart';
import 'package:chatapp/models/firestore_helper.dart';
import 'package:chatapp/screens/5-settings_screen/update_password_form.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen(this.authService, this.dbHelper, {super.key});

  final AuthService authService;
  final FirestoreHelper dbHelper;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserEntry? userInfo;
  late String email;

  // TextStyle for titles
  TextStyle titleTextStyle = const TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w400,
  );

  @override
  void initState() {
    super.initState();

    email = widget.authService.getEmail();

    widget.dbHelper.getUserEntryFromEmail(email).then((result) {
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
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(64.0),
        child: Column(
          children: [
            Text('Update Password', style: titleTextStyle),
            SizedBox(height: 20),
            UpdatePasswordForm(widget.authService, widget.dbHelper),
            SizedBox(height: 20),
            Text('Log out', style: titleTextStyle),
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
    );
  }
}
