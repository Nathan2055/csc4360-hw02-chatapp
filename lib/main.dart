import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chatapp/firebase_options.dart';
import 'package:chatapp/authservice.dart';
import 'package:chatapp/screens/create_account_screen.dart';
import 'package:chatapp/screens/login_screen.dart';
import 'package:chatapp/screens/profile_screen.dart';

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
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Tracking variables for which interface is selected
  bool loginSelected = false;
  bool createAccountSelected = false;

  // Decide which interface to display based on selection
  Scaffold renderAuthInterface() {
    // If somehow both options get selected, reset them both
    if (loginSelected && createAccountSelected) {
      setState(() {
        loginSelected = false;
        createAccountSelected = false;
      });
    }

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(64.0),
          child: Column(
            children: [
              // If the login screen is selected, render the login screen
              loginSelected ? AppBar(title: const Text('Log In')) : Container(),
              loginSelected ? LoginScreen() : Container(),

              // If the create account screen is selected, render the create account screen
              createAccountSelected
                  ? AppBar(title: const Text('Create Account'))
                  : Container(),
              createAccountSelected ? CreateAccountScreen() : Container(),

              SizedBox(height: 16.0),
              backButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Starting interface to select between logging in and creating account
  Scaffold renderStartingScreen() {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(64.0),
          child: Column(
            spacing: 24.0,
            children: [
              AppBar(title: const Text('Firebase Chat App')),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    loginSelected = true;
                  });
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text('Login')],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    createAccountSelected = true;
                  });
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text('Create Account')],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ElevatedButton backButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          loginSelected = false;
          createAccountSelected = false;
        });
      },
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text('Back')],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: StreamBuilder<User?>(
        stream: widget.authService.getStream(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          // Display this if an error occurs
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(64.0),
                  child: Column(
                    children: [
                      AppBar(title: const Text('Something went wrong')),
                    ],
                  ),
                ),
              ),
            );
          }

          // Display this while connecting to Firebase
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(64.0),
                  child: Column(
                    children: [AppBar(title: const Text('Loading...'))],
                  ),
                ),
              ),
            );
          }

          // Display this if the user is not logged in yet
          if (!snapshot.hasData) {
            if (!loginSelected && !createAccountSelected) {
              return renderStartingScreen();
            } else {
              return renderAuthInterface();
            }
          }

          // Display this once the user is logged in
          return ProfileScreen(emailAddress: widget.authService.getEmail());
        },
      ),
    );
  }
}
