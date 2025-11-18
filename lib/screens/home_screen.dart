import 'package:flutter/material.dart';
import 'package:chatapp/authservice.dart';
import 'package:chatapp/models/user_entry.dart';
import 'package:chatapp/models/user_database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen(this.authService, {super.key});

  final AuthService authService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppBar homeScreenAppBar = AppBar(title: const Text('Firebase Chat App'));

  AppBar setup = AppBar(
    title: const Text('Firebase Chat App'),
    actions: <Widget>[
      // This button is where the magic happens
      IconButton(
        // The icon and tooltip is also provided by the theme model
        icon: Provider.of<ThemeModel>(context).themeIcon,
        tooltip: Provider.of<ThemeModel>(context).themeText,
        // toggleThemeMode is called to globally update the current theme
        onPressed: () {
          var model = context.read<ThemeModel>();
          model.toggleThemeMode();
        },
      ),

      IconButton(
        icon: const Icon(Icons.home),
        tooltip: 'Home',
        onPressed: _updateVisibleScreen('home'),
      ),

      IconButton(
        icon: const Icon(Icons.person),
        tooltip: 'Profile',
        onPressed: _updateVisibleScreen('profile'),
      ),

      IconButton(
        icon: const Icon(Icons.settings),
        tooltip: 'Settings',
        onPressed: _updateVisibleScreen('settings'),
      ),
    ],
  );

  String _visibleScreen = 'home';
  void _updateVisibleScreen(String newScreen) {
    setState(() {
      _visibleScreen = newScreen;
    });
  }

  UserDatabase userDB = UserDatabase();

  UserEntry? userInfo;
  late String email;

  @override
  void initState() {
    super.initState();

    homeScreenAppBar = AppBar(
      title: const Text('Firebase Chat App'),
      actions: <Widget>[
        // This button is where the magic happens
        IconButton(
          // The icon and tooltip is also provided by the theme model
          icon: Provider.of<ThemeModel>(context).themeIcon,
          tooltip: Provider.of<ThemeModel>(context).themeText,
          // toggleThemeMode is called to globally update the current theme
          onPressed: () {
            var model = context.read<ThemeModel>();
            model.toggleThemeMode();
          },
        ),

        IconButton(
          icon: const Icon(Icons.home),
          tooltip: 'Home',
          onPressed: () {
            _updateVisibleScreen('home');
          },
          onPressed: _updateVisibleScreen('home'),
        ),

        IconButton(
          icon: const Icon(Icons.person),
          tooltip: 'Profile',
          onPressed: _updateVisibleScreen('profile'),
        ),

        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: 'Settings',
          onPressed: _updateVisibleScreen('settings'),
        ),
      ],
    );

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
    Map? user1;
    String? user2;

    if (userInfo != null) {
      user1 = userInfo!.toFirestore();
      user2 = user1.toString();
    }

    return Scaffold(
      appBar: homeScreenAppBar,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(64.0),
          child: Column(
            children: [
              Text('Welcome! Your email is $email'),
              SizedBox(height: 20),
              Text('Other profile information:'),
              SizedBox(height: 20),
              (user2 != null) ? Text(user2) : Container(),
              (user2 != null) ? SizedBox(height: 20) : Container(),
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
