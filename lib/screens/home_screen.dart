import 'package:flutter/material.dart';
import 'package:chatapp/authservice.dart';
import 'package:chatapp/models/user_entry.dart';
import 'package:chatapp/models/firestore_helper.dart';
import 'package:chatapp/screens/4-profile_screen/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen(this.authService, this.dbHelper, {super.key});

  final AuthService authService;
  final FirestoreHelper dbHelper;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AppBar homeScreenAppBar;

  late Column _homePlaceholder;

  String _visibleScreen = 'home';

  UserEntry? _userInfo;
  late String _email;
  late String _userInfoString;

  @override
  void initState() {
    super.initState();

    _email = widget.authService.getEmail();

    widget.dbHelper.getUserEntryFromEmail(_email).then((result) {
      setState(() {
        if (result != null) {
          _userInfo = result;
        }
      });
    });

    _userInfoString = _userInfo!.toFirestore().toString();

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

    _homePlaceholder = Column(
      children: [
        /*
        (_visibleScreen == 'profile')
            ? Text('Profile screen enabled')
            : Container(),
        (_visibleScreen == 'settings')
            ? Text('Settings screen enabled')
            : Container(),
        (_visibleScreen != 'home') ? SizedBox(height: 20) : Container(),
        */
        Text('Welcome! Your email is $_email'),
        SizedBox(height: 20),
        Text('Other profile information:'),
        SizedBox(height: 20),
        (_userInfoString != null) ? Text(_userInfoString) : Container(),
        (_userInfoString != null) ? SizedBox(height: 20) : Container(),
        ElevatedButton(
          onPressed: _logout,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('Log out')],
          ),
        ),
      ],
    );
  }

  void _logout() {
    widget.authService.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeScreenAppBar,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(64.0),
          child: Column(
            children: [
              (_visibleScreen == 'home') ? _homePlaceholder : Container(),
              (_visibleScreen == 'profile')
                  ? ProfileScreen(widget.authService, widget.dbHelper)
                  : Container(),
              (_visibleScreen == 'settings') ? _homePlaceholder : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
