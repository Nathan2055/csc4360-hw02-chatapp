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
  MyApp({super.key});

  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Chat App',
      home: MyHomePage(authService),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage(this.authService, {super.key});
  final Duration delay = const Duration(seconds: 1);
  final AuthService authService;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // TextStyle for titles
  TextStyle titleTextStyle = const TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w400,
  );

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
              loginSelected
                  ? Column(
                      spacing: 24.0,
                      children: [
                        Text('Log In', style: titleTextStyle),
                        LoginScreen(widget.authService),
                      ],
                    )
                  : Container(),

              // If the create account screen is selected, render the create account screen
              createAccountSelected
                  ? Column(
                      spacing: 24.0,
                      children: [
                        Text('Create Account', style: titleTextStyle),
                        CreateAccountScreen(widget.authService),
                      ],
                    )
                  : Container(),

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
              Text('Firebase Chat App', style: titleTextStyle),
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
      appBar: AppBar(title: Text('Firebase Chat App')),
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
                      Text('Something went wrong', style: titleTextStyle),
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
                    children: [Text('Loading...', style: titleTextStyle)],
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
