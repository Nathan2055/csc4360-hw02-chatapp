import 'package:flutter/material.dart';
import 'package:chatapp/authservice.dart';
import 'package:chatapp/models/user_entry.dart';
import 'package:chatapp/models/firestore_helper.dart';
import 'package:chatapp/screens/4-profile_screen/profile_screen.dart';
import 'package:chatapp/screens/5-settings_screen/settings_screen.dart';

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
  late Column _homeColumn;

  String _visibleScreen = 'home';

  UserEntry? _userInfo;
  late String _email;
  String? _userInfoString;

  @override
  void initState() {
    super.initState();

    _email = widget.authService.getEmail();

    widget.dbHelper.getUserEntryFromEmail(_email).then((result) {
      if (result != null) {
        setState(() {
          _userInfo = result;
          _userInfoString = _userInfo!.toFirestore().toString();
          _buildHomeScreenAppBar();
          _buildHomePlaceholder();
          _buildHomeColumn();
        });
      }
    });

    _buildHomeScreenAppBar();
    _buildHomePlaceholder();
    _buildHomeColumn();
  }

  void _buildHomeScreenAppBar() {
    setState(() {
      homeScreenAppBar = AppBar(
        title: const Text('Firebase Chat App'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Home',
            onPressed: () {
              setState(() {
                _visibleScreen = 'home';
                _buildHomeColumn();
              });
            },
          ),

          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () {
              setState(() {
                _visibleScreen = 'profile';
                _buildHomeColumn();
              });
            },
          ),

          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              setState(() {
                _visibleScreen = 'settings';
                _buildHomeColumn();
              });
            },
          ),
        ],
      );
    });
  }

  void _buildHomePlaceholder() {
    setState(() {
      _homePlaceholder = Column(
        children: [
          Text('Welcome! Your email is $_email'),
          SizedBox(height: 20),
          Text('Other profile information:'),
          SizedBox(height: 20),
          (_userInfoString != null) ? Text(_userInfoString!) : Container(),
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
    });
  }

  void _buildHomeColumn() {
    setState(() {
      _homeColumn = Column(
        children: [
          (_visibleScreen == 'home') ? _homePlaceholder : Container(),
          (_visibleScreen == 'profile')
              ? ProfileScreen(widget.authService, widget.dbHelper)
              : Container(),
          (_visibleScreen == 'settings')
              ? SettingsScreen(widget.authService, widget.dbHelper)
              : Container(),
        ],
      );
    });
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
          child: _homeColumn,
        ),
      ),
    );
  }
}
