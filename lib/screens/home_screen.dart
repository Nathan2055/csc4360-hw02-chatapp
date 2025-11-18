import 'package:flutter/material.dart';
import 'package:chatapp/authservice.dart';
import 'package:chatapp/models/user_entry.dart';
import 'package:chatapp/models/firestore_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen(this.authService, this.dbHelper, {super.key});

  final AuthService authService;
  final FirestoreHelper dbHelper;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppBar homeScreenAppBar = AppBar(title: const Text('Firebase Chat App'));

  String _visibleScreen = 'home';

  UserEntry? userInfo;
  late String email;

  @override
  void initState() {
    super.initState();

    homeScreenAppBar = AppBar(
      title: const Text('Firebase Chat App'),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.home),
          tooltip: 'Home',
          onPressed: () {
            setState(() {
              _visibleScreen = 'home';
            });
          },
        ),

        IconButton(
          icon: const Icon(Icons.person),
          tooltip: 'Profile',
          onPressed: () {
            setState(() {
              _visibleScreen = 'profile';
            });
          },
        ),

        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: 'Settings',
          onPressed: () {
            setState(() {
              _visibleScreen = 'settings';
            });
          },
        ),
      ],
    );

    email = widget.authService.getEmail();

    widget.dbHelper.getUserEntryFromEmail(email).then((result) {
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
    String userInfoString = userInfo!.toFirestore().toString();

    return Scaffold(
      appBar: homeScreenAppBar,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(64.0),
          child: Column(
            children: [
              (_visibleScreen == 'profile')
                  ? Text('Profile screen enabled')
                  : Container(),
              (_visibleScreen == 'settings')
                  ? Text('Settings screen enabled')
                  : Container(),
              (_visibleScreen != 'home') ? SizedBox(height: 20) : Container(),
              Text('Welcome! Your email is $email'),
              SizedBox(height: 20),
              Text('Other profile information:'),
              SizedBox(height: 20),
              (userInfoString != null) ? Text(userInfoString) : Container(),
              (userInfoString != null) ? SizedBox(height: 20) : Container(),
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
