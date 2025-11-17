import 'package:flutter/material.dart';
import 'package:chatapp/authservice.dart';
import 'package:chatapp/screens/2-message_boards_listing/board_card.dart';

class MessageBoardsListing extends StatefulWidget {
  const MessageBoardsListing(this.authService, {super.key});
  final AuthService authService;

  @override
  State<MessageBoardsListing> createState() => _MessageBoardsListingState();
}

class _MessageBoardsListingState extends State<MessageBoardsListing> {
  // TextStyle for titles
  TextStyle titleTextStyle = const TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w400,
  );

  Column renderBoardsListing() {
    return Column(
      spacing: 24.0,
      children: [
        Text('Message Boards', style: titleTextStyle),
        BoardCard(
          icon: Icons.games,
          title: 'Games',
          color: Colors.orange,
          targetScreen: Container(), // TODO: link out to board
        ),
        BoardCard(
          icon: Icons.show_chart,
          title: 'Business',
          color: Colors.teal,
          targetScreen: Container(), // TODO: link out to board
        ),
        BoardCard(
          icon: Icons.health_and_safety,
          title: 'Public Health',
          color: Colors.pinkAccent,
          targetScreen: Container(), // TODO: link out to board
        ),
        BoardCard(
          icon: Icons.school,
          title: 'Study',
          color: Colors.purple,
          targetScreen: Container(), // TODO: link out to board
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Firebase Chat App')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(64.0),
          child: renderBoardsListing(),
        ),
      ),
    );
  }
}
