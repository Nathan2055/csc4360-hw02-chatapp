import 'package:firebaseauth/authservice.dart';
import 'package:firebaseauth/screens/create_account_screen.dart';
import 'package:firebaseauth/screens/login_screen.dart';
import 'package:firebaseauth/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebaseauth/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Firebase Auth Demo', home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});
  final String title = 'Firebase Auth Demo';
  final Duration delay = const Duration(seconds: 1);
  final AuthService authService = AuthService();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: StreamBuilder<User?>(
        stream: widget.authService.getStream(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading...");
          }

          if (!snapshot.hasData) {
            return Scaffold(
              body: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(64.0),
                  child: Column(
                    children: [
                      AppBar(title: const Text('Log In')),
                      LoginScreen(),
                      AppBar(title: const Text('Create Account')),
                      CreateAccountScreen(),
                    ],
                  ),
                ),
              ),
            );
          }
          return ProfileScreen(emailAddress: widget.authService.getEmail());
        },
      ),
    );
  }
}
