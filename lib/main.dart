import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chatapp/firebase_options.dart';
import 'package:chatapp/authservice.dart';
import 'package:chatapp/screens/1-welcome_screen/welcome_screen.dart';
import 'package:chatapp/screens/2-message_boards_listing/message_boards_listing.dart';

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
      home: MessageBoardsListing(authService),
      //home: WelcomeScreen(authService),
    );
  }
}
